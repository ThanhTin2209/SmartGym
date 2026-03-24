using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SmartGymAPI.Migrations
{
    /// <inheritdoc />
    public partial class InitSmartGymV3 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "ProductCategories",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2025, 12, 21, 22, 13, 41, 406, DateTimeKind.Utc).AddTicks(9017));

            migrationBuilder.UpdateData(
                table: "ProductCategories",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2025, 12, 21, 22, 13, 41, 406, DateTimeKind.Utc).AddTicks(9021));

            migrationBuilder.UpdateData(
                table: "ProductCategories",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2025, 12, 21, 22, 13, 41, 406, DateTimeKind.Utc).AddTicks(9023));

            migrationBuilder.UpdateData(
                table: "ProductCategories",
                keyColumn: "Id",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2025, 12, 21, 22, 13, 41, 406, DateTimeKind.Utc).AddTicks(9024));

            migrationBuilder.UpdateData(
                table: "ProductCategories",
                keyColumn: "Id",
                keyValue: 5,
                column: "CreatedAt",
                value: new DateTime(2025, 12, 21, 22, 13, 41, 406, DateTimeKind.Utc).AddTicks(9025));

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2025, 12, 21, 22, 13, 41, 406, DateTimeKind.Utc).AddTicks(9046));

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2025, 12, 21, 22, 13, 41, 406, DateTimeKind.Utc).AddTicks(9058));

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2025, 12, 21, 22, 13, 41, 406, DateTimeKind.Utc).AddTicks(9060));

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "Id",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2025, 12, 21, 22, 13, 41, 406, DateTimeKind.Utc).AddTicks(9061));

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "Id",
                keyValue: 5,
                column: "CreatedAt",
                value: new DateTime(2025, 12, 21, 22, 13, 41, 406, DateTimeKind.Utc).AddTicks(9062));

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "Id",
                keyValue: 6,
                column: "CreatedAt",
                value: new DateTime(2025, 12, 21, 22, 13, 41, 406, DateTimeKind.Utc).AddTicks(9064));

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "Id",
                keyValue: 7,
                column: "CreatedAt",
                value: new DateTime(2025, 12, 21, 22, 13, 41, 406, DateTimeKind.Utc).AddTicks(9065));

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "Id",
                keyValue: 8,
                column: "CreatedAt",
                value: new DateTime(2025, 12, 21, 22, 13, 41, 406, DateTimeKind.Utc).AddTicks(9066));
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "ProductCategories",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2025, 12, 21, 10, 38, 59, 400, DateTimeKind.Utc).AddTicks(2597));

            migrationBuilder.UpdateData(
                table: "ProductCategories",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2025, 12, 21, 10, 38, 59, 400, DateTimeKind.Utc).AddTicks(2601));

            migrationBuilder.UpdateData(
                table: "ProductCategories",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2025, 12, 21, 10, 38, 59, 400, DateTimeKind.Utc).AddTicks(2602));

            migrationBuilder.UpdateData(
                table: "ProductCategories",
                keyColumn: "Id",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2025, 12, 21, 10, 38, 59, 400, DateTimeKind.Utc).AddTicks(2603));

            migrationBuilder.UpdateData(
                table: "ProductCategories",
                keyColumn: "Id",
                keyValue: 5,
                column: "CreatedAt",
                value: new DateTime(2025, 12, 21, 10, 38, 59, 400, DateTimeKind.Utc).AddTicks(2604));

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2025, 12, 21, 10, 38, 59, 400, DateTimeKind.Utc).AddTicks(2619));

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2025, 12, 21, 10, 38, 59, 400, DateTimeKind.Utc).AddTicks(2626));

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2025, 12, 21, 10, 38, 59, 400, DateTimeKind.Utc).AddTicks(2628));

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "Id",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2025, 12, 21, 10, 38, 59, 400, DateTimeKind.Utc).AddTicks(2629));

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "Id",
                keyValue: 5,
                column: "CreatedAt",
                value: new DateTime(2025, 12, 21, 10, 38, 59, 400, DateTimeKind.Utc).AddTicks(2631));

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "Id",
                keyValue: 6,
                column: "CreatedAt",
                value: new DateTime(2025, 12, 21, 10, 38, 59, 400, DateTimeKind.Utc).AddTicks(2632));

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "Id",
                keyValue: 7,
                column: "CreatedAt",
                value: new DateTime(2025, 12, 21, 10, 38, 59, 400, DateTimeKind.Utc).AddTicks(2633));

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "Id",
                keyValue: 8,
                column: "CreatedAt",
                value: new DateTime(2025, 12, 21, 10, 38, 59, 400, DateTimeKind.Utc).AddTicks(2634));
        }
    }
}
