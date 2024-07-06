// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract ProductTracker {
    // state variable
    struct Product {
        uint256 productId;
        string productType;
        string brandName;
        string productName;
        string[] Materials;
        string[] Certificates;
        uint256 quantity;
        Location location;
    }

    struct Location {
        string name;
        string custodian;
        uint256 departure;
        bool shipped;
        bool arrived;
        uint256 arrival;
    }

    mapping(uint256 => Product) public products;

    // events
    event ProductGenerated(
        uint256 indexed productId,
        string productType,
        string brandName,
        string productName,
        string[] materials,
        string[] certificates,
        uint256 quantity
    );

    event Departed(
        string location,
        string custodian,
        uint256 time,
        uint256 index,
        bool arrivalStatus
    );

    modifier productExisted(uint256 _productId) {
        // Check if product exists
        require(
            products[_productId].productId != _productId,
            "Product does not exist"
        );
        require(products[_productId].quantity != 0, "Product is out of stock");
        require(
            products[_productId].location.shipped == true,
            "Product has been shipped"
        );
        _;
    }

    function GenerateProduct(
        string memory _productType,
        string memory _productName,
        string memory _brandName,
        string[] memory _materials,
        string[] memory _certificates,
        uint256 _quantity,
        string memory _locationName, // Optional location name
        string memory _custodian,
        bool _shipped
    ) public {
        // Validate product details directly within the function
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

        uint256 _productId = block.timestamp;
        require(products[_productId].productId == 0, "Product already exists");

        products[_productId] = Product(
            _productId,
            _productType,
            _brandName,
            _productName,
            _materials,
            _certificates,
            _quantity,
            Location({
                name: _locationName,
                custodian: _custodian,
                shipped: _shipped,
                departure: _shipped ? block.timestamp : 0,
                arrived: false, // Set default values for other fields
                arrival: 0
            })
        );

        emit ProductGenerated(
            _productId,
            _productType,
            _brandName,
            _productName,
            _materials,
            _certificates,
            _quantity
        );
    }

    function initalizeShipment(uint256 _productId, string memory _locationName)
        public
        productExisted(_productId)
    {
        products[_productId].location.name = _locationName;
        products[_productId].location.departure = block.timestamp;
        products[_productId].location.shipped = true;

        emit Departed(
            products[_productId].location.name,
            products[_productId].location.custodian,
            block.timestamp,
            _productId,
            products[_productId].location.arrived
        );
    }
}
