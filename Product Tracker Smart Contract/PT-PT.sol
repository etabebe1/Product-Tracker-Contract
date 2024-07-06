// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract ProductTracker {
    // state variable
    struct Product {
        uint256 productId;
        string productName;
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
        string productName,
        uint256 quantity
    );

    event Departed(
        string location,
        string custodian,
        uint256 time,
        uint256 index,
        bool arrivalStatus
    );

    // Modifire
    modifier productExisted(uint256 _productId) {
        // Check if product exists
        require(
            products[_productId].productId != _productId,
            "Product does not exist"
        );
        _;
    }

    function addProduct(
        string memory _productName,
        uint256 _quantity,
        string memory _locationName, // Optional location name
        string memory _custodian,
        bool _shipped
    ) public {
        uint256 _productId = block.timestamp;
        require(products[_productId].productId == 0, "Product already exists");

        products[_productId] = Product(
            _productId,
            _productName,
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

        emit ProductGenerated(_productId, _productName, _quantity);
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
