using System;

namespace SmartGymAPI.Services
{
    public class BlockchainService
    {
        // Mock wallet generation
        public static (string Address, string PrivateKey) GenerateWallet()
        {
            var guid = Guid.NewGuid().ToString("N");
            var address = "GYM" + guid.Substring(0, 16).ToUpper();
            var privateKey = guid + Guid.NewGuid().ToString("N");
            return (address, privateKey);
        }
    }
}
