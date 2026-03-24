using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SmartGymAPI.Data;
using SmartGymAPI.Models;
using System.Security.Claims;

namespace SmartGymAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class OrderController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public OrderController(ApplicationDbContext context)
        {
            _context = context;
        }

        private string GetUserId() => User.FindFirstValue(ClaimTypes.NameIdentifier) ?? "";

        // GET: api/Order (User's orders)
        [HttpGet]
        public async Task<IActionResult> GetMyOrders()
        {
            var userId = GetUserId();
            var orders = await _context.Orders
                .Include(o => o.OrderItems)
                .ThenInclude(oi => oi.Product)
                .Where(o => o.UserId == userId)
                .OrderByDescending(o => o.CreatedAt)
                .ToListAsync();

            return Ok(orders);
        }

        // GET: api/Order/{id}
        [HttpGet("{id}")]
        public async Task<IActionResult> GetOrderById(int id)
        {
            var userId = GetUserId();
            var order = await _context.Orders
                .Include(o => o.OrderItems)
                .ThenInclude(oi => oi.Product)
                .FirstOrDefaultAsync(o => o.Id == id && o.UserId == userId);

            if (order == null) return NotFound();
            return Ok(order);
        }

        // POST: api/Order/checkout
        [HttpPost("checkout")]
        public async Task<IActionResult> Checkout([FromBody] CheckoutDto dto)
        {
            var userId = GetUserId();
            
            // Get cart items
            var cartItems = await _context.CartItems
                .Include(c => c.Product)
                .Where(c => c.UserId == userId)
                .ToListAsync();

            if (!cartItems.Any()) return BadRequest("Giỏ hàng trống");

            // Check stock availability
            foreach (var item in cartItems)
            {
                if (item.Product.Stock < item.Quantity)
                    return BadRequest($"Sản phẩm {item.Product.Name} không đủ hàng");
            }

            decimal totalAmount = cartItems.Sum(c => c.Product.Price * c.Quantity);
            decimal discount = 0;
            decimal coinsToUse = 0;

            if (dto.UseGymCoins)
            {
                var profile = await _context.HealthProfiles.FirstOrDefaultAsync(h => h.UserId == userId);
                if (profile != null && profile.GymCoinBalance > 0)
                {
                     // Rate: 100 Coins = 5,000 VND => 1 Coin = 50 VND
                     decimal coinValue = 50;
                     decimal maxDiscount = totalAmount * 0.5m;
                     decimal potentialDiscount = profile.GymCoinBalance * coinValue;
                     
                     discount = Math.Min(potentialDiscount, maxDiscount);
                     coinsToUse = discount / coinValue;

                     if (coinsToUse > 0)
                     {
                         profile.GymCoinBalance -= coinsToUse;
                         _context.HealthProfiles.Update(profile);

                         // Transaction log
                         var trans = new GymCoinTransaction
                         {
                             UserId = userId,
                             Amount = -coinsToUse,
                             Type = "Spend",
                             Description = $"Thanh toán đơn hàng Shop (-{discount:N0}đ)",
                             CreatedAt = DateTime.UtcNow
                         };
                         _context.GymCoinTransactions.Add(trans);
                     }
                }
            }

            // Create order
            var order = new Order
            {
                UserId = userId,
                TotalAmount = totalAmount - discount,
                Status = "Pending",
                ShippingAddress = dto.ShippingAddress,
                PhoneNumber = dto.PhoneNumber,
                Notes = dto.Notes ?? ((coinsToUse > 0) ? $"Đã dùng {coinsToUse:N0} Coin giảm {discount:N0}đ" : "")
            };

            _context.Orders.Add(order);
            await _context.SaveChangesAsync();

            // Create order items and reduce stock
            foreach (var cartItem in cartItems)
            {
                var orderItem = new OrderItem
                {
                    OrderId = order.Id,
                    ProductId = cartItem.ProductId,
                    ProductName = cartItem.Product.Name,
                    Price = cartItem.Product.Price,
                    Quantity = cartItem.Quantity
                };
                _context.OrderItems.Add(orderItem);

                // Reduce stock
                cartItem.Product.Stock -= cartItem.Quantity;
            }

            // Clear cart
            _context.CartItems.RemoveRange(cartItems);
            await _context.SaveChangesAsync();

            return Ok(new { orderId = order.Id, message = "Đặt hàng thành công" });
        }

        // GET: api/Order/admin/all (Admin only)
        [Authorize(Roles = "Admin")]
        [HttpGet("admin/all")]
        public async Task<IActionResult> GetAllOrders([FromQuery] string? status)
        {
            var query = _context.Orders
                .Include(o => o.User)
                .Include(o => o.OrderItems)
                .ThenInclude(oi => oi.Product)
                .AsQueryable();

            if (!string.IsNullOrEmpty(status))
                query = query.Where(o => o.Status == status);

            var orders = await query.OrderByDescending(o => o.CreatedAt).ToListAsync();
            return Ok(orders);
        }

        // PUT: api/Order/admin/{id}/status (Admin only)
        [Authorize(Roles = "Admin")]
        [HttpPut("admin/{id}/status")]
        public async Task<IActionResult> UpdateOrderStatus(int id, [FromBody] UpdateStatusDto dto)
        {
            var order = await _context.Orders.FindAsync(id);
            if (order == null) return NotFound();

            order.Status = dto.Status;
            await _context.SaveChangesAsync();
            return Ok(order);
        }
        // POST: api/Order/webhook/payment-handler
        [AllowAnonymous] // Allow external services (like banks) to call this
        [HttpPost("webhook/payment-handler")]
        public async Task<IActionResult> PaymentHandler([FromBody] PaymentWebhookDto dto)
        {
            // Simple logic: parsing content to find OrderId
            // Example content: "Thanh toan don hang 123" => OrderId = 123
            
            if (string.IsNullOrEmpty(dto.Content)) return BadRequest("Content is empty");

            int orderId = 0;
            var words = dto.Content.Split(' ');
            if (words.Length > 0 && int.TryParse(words.Last(), out int parsedId))
            {
                orderId = parsedId;
            }

            if (orderId == 0) return BadRequest("Cannot parse OrderId from content");

            var order = await _context.Orders.FindAsync(orderId);
            if (order == null) return NotFound("Order not found");

            if (order.Status == "Completed") return Ok("Order already completed");

            // Verify amount (optional, simplified for demo)
            // if (order.TotalAmount > dto.Amount) return BadRequest("Insufficient amount");

            order.Status = "Completed";
            await _context.SaveChangesAsync();

            return Ok(new { success = true, orderId = order.Id, message = "Payment confirmed" });
        }

        // POST: api/Order/simulate-payment (Demo only)
        [HttpPost("simulate-payment")]
        public async Task<IActionResult> SimulatePayment([FromBody] SimulatePaymentDto dto)
        {
            // Internal call to logic
            var order = await _context.Orders.FindAsync(dto.OrderId);
            if (order == null) return NotFound("Order not found");
            
            order.Status = "Completed";
            await _context.SaveChangesAsync();

            return Ok(new { success = true, message = $"Simulated payment for Order #{dto.OrderId}" });
        }
    }

    public class CheckoutDto
    {
        public string ShippingAddress { get; set; } = "";
        public string PhoneNumber { get; set; } = "";
        public string? Notes { get; set; }
        public bool UseGymCoins { get; set; } = false;
    }

    public class UpdateStatusDto
    {
        public string Status { get; set; } = "";
    }

    public class PaymentWebhookDto
    {
        public decimal Amount { get; set; }
        public string Content { get; set; } = "";
        public string Gateway { get; set; } = "BankTransfer";
    }

    public class SimulatePaymentDto
    {
        public int OrderId { get; set; }
    }
}
