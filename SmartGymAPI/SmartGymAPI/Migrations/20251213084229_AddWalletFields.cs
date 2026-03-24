using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SmartGymAPI.Migrations
{
    /// <inheritdoc />
    public partial class AddWalletFields : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<decimal>(
                name: "GymCoinBalance",
                table: "HealthProfiles",
                type: "decimal(18,2)",
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.AddColumn<string>(
                name: "PrivateKey",
                table: "HealthProfiles",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "WalletAddress",
                table: "HealthProfiles",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.UpdateData(
                table: "ProductCategories",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2025, 12, 13, 8, 42, 28, 921, DateTimeKind.Utc).AddTicks(6853));

            migrationBuilder.UpdateData(
                table: "ProductCategories",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2025, 12, 13, 8, 42, 28, 921, DateTimeKind.Utc).AddTicks(6859));

            migrationBuilder.UpdateData(
                table: "ProductCategories",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2025, 12, 13, 8, 42, 28, 921, DateTimeKind.Utc).AddTicks(6862));

            migrationBuilder.UpdateData(
                table: "ProductCategories",
                keyColumn: "Id",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2025, 12, 13, 8, 42, 28, 921, DateTimeKind.Utc).AddTicks(6864));

            migrationBuilder.UpdateData(
                table: "ProductCategories",
                keyColumn: "Id",
                keyValue: 5,
                column: "CreatedAt",
                value: new DateTime(2025, 12, 13, 8, 42, 28, 921, DateTimeKind.Utc).AddTicks(6866));

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2025, 12, 13, 8, 42, 28, 921, DateTimeKind.Utc).AddTicks(6899));

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2025, 12, 13, 8, 42, 28, 921, DateTimeKind.Utc).AddTicks(6909));

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2025, 12, 13, 8, 42, 28, 921, DateTimeKind.Utc).AddTicks(6913));

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "Id",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2025, 12, 13, 8, 42, 28, 921, DateTimeKind.Utc).AddTicks(6916));

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "Id",
                keyValue: 5,
                column: "CreatedAt",
                value: new DateTime(2025, 12, 13, 8, 42, 28, 921, DateTimeKind.Utc).AddTicks(6919));

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "Id",
                keyValue: 6,
                column: "CreatedAt",
                value: new DateTime(2025, 12, 13, 8, 42, 28, 921, DateTimeKind.Utc).AddTicks(6921));

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "Id",
                keyValue: 7,
                column: "CreatedAt",
                value: new DateTime(2025, 12, 13, 8, 42, 28, 921, DateTimeKind.Utc).AddTicks(6924));

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "Id",
                keyValue: 8,
                column: "CreatedAt",
                value: new DateTime(2025, 12, 13, 8, 42, 28, 921, DateTimeKind.Utc).AddTicks(6927));
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "GymCoinBalance",
                table: "HealthProfiles");

            migrationBuilder.DropColumn(
                name: "PrivateKey",
                table: "HealthProfiles");

            migrationBuilder.DropColumn(
                name: "WalletAddress",
                table: "HealthProfiles");

            migrationBuilder.UpdateData(
                table: "ProductCategories",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2025, 12, 12, 17, 29, 47, 941, DateTimeKind.Utc).AddTicks(1799));

            migrationBuilder.UpdateData(
                table: "ProductCategories",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2025, 12, 12, 17, 29, 47, 941, DateTimeKind.Utc).AddTicks(1803));

            migrationBuilder.UpdateData(
                table: "ProductCategories",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2025, 12, 12, 17, 29, 47, 941, DateTimeKind.Utc).AddTicks(1804));

            migrationBuilder.UpdateData(
                table: "ProductCategories",
                keyColumn: "Id",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2025, 12, 12, 17, 29, 47, 941, DateTimeKind.Utc).AddTicks(1805));

            migrationBuilder.UpdateData(
                table: "ProductCategories",
                keyColumn: "Id",
                keyValue: 5,
                column: "CreatedAt",
                value: new DateTime(2025, 12, 12, 17, 29, 47, 941, DateTimeKind.Utc).AddTicks(1806));

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2025, 12, 12, 17, 29, 47, 941, DateTimeKind.Utc).AddTicks(1824));

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2025, 12, 12, 17, 29, 47, 941, DateTimeKind.Utc).AddTicks(1830));

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2025, 12, 12, 17, 29, 47, 941, DateTimeKind.Utc).AddTicks(1831));

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "Id",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2025, 12, 12, 17, 29, 47, 941, DateTimeKind.Utc).AddTicks(1833));

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "Id",
                keyValue: 5,
                column: "CreatedAt",
                value: new DateTime(2025, 12, 12, 17, 29, 47, 941, DateTimeKind.Utc).AddTicks(1834));

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "Id",
                keyValue: 6,
                column: "CreatedAt",
                value: new DateTime(2025, 12, 12, 17, 29, 47, 941, DateTimeKind.Utc).AddTicks(1836));

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "Id",
                keyValue: 7,
                column: "CreatedAt",
                value: new DateTime(2025, 12, 12, 17, 29, 47, 941, DateTimeKind.Utc).AddTicks(1837));

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "Id",
                keyValue: 8,
                column: "CreatedAt",
                value: new DateTime(2025, 12, 12, 17, 29, 47, 941, DateTimeKind.Utc).AddTicks(1838));
        }
    }
}
