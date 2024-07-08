// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

library ValidationLibrary {
    function validateProductDetails(
        string memory _productType,
        string memory _productName,
        string memory _brandName,
        uint256 _quantity
    ) public pure returns (bool) {
        // Implement your validation logic here
        require(
            bytes(_productType).length > 0,
            "Empty product type not allowed"
        );
        require(
            bytes(_productName).length > 0,
            "Empty product name not allowed"
        );
        require(bytes(_brandName).length > 0, "Empty brand name not allowed");
        require(_quantity > 0, "Quantity must be greater than zero");
    }
}
