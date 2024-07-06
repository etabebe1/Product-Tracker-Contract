// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol"; // Include Roles library

/**
 * @title ProductTracker
 * This contract allows tracking of products in a supply chain with various attributes and location details.
 */
contract ProductTracker is Ownable(msg.sender), AccessControl {
    bytes32 public constant AUTHORIZED_ROLE = keccak256("AUTHORIZED_ROLE");

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
    /// mapping for authorizedUsers is substituted by AccessControl.sol from openzeppelin
    // mapping(address => bool) public authorizedUsers;

    // Events
    event ProductGenerated(
        uint256 indexed productId,
        string productType,
        string brandName,
        string productName,
        string[] materials,
        string[] certificates,
        uint256 quantity,
        Location location 
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
            products[_productId].location.shipped != false,
            "Product has been shipped"
        );
        require(
            products[_productId].productId == _productId,
            "Product does not exist"
        );
        require(products[_productId].quantity != 0, "Product is out of stock");
        _;
    }

    modifier onlyAuthorized() {
        require(hasRole(AUTHORIZED_ROLE, msg.sender), "User not authorized");
        _;
    }

    // function getOwner() public view returns (address) {
    //     return owner();
    // }

    function grantAuthorization(address _userAddress) public onlyOwner {
        _grantRole(AUTHORIZED_ROLE, _userAddress);
    }

    function revokeAuthorization(address _userAddress) public onlyOwner {
        _revokeRole(AUTHORIZED_ROLE, _userAddress);
    }

    /**
     * @dev Generates a new product with the given details. The function can only be called by authorized users.
     *
     * Requirements:
     * - Caller must have the AUTHORIZED_ROLE.
     * - Product type, name, brand name, materials and certificates should not be empty.
     * - Quantity must be greater than zero.
     *
     * @param _productType The type of product.
     * @param _productName The name of the product.
     * @param _brandName The brand name of the product.
     * @param _materials Array of materials used in making the product.
     * @param _certificates Array of certificates related to the product.
     * @param _quantity Quantity of the product.
     * @param _locationName Optional location name where the product is initially stored.
     * @param _custodian Name of the custodian for this product.
     * @param _shipped Indicates if the product has been shipped or not.
     */

    // FUNCTION TO GENERATE PRODUCT
    // Only access authorized user have access to call this function
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
    ) public onlyAuthorized {
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
            _quantity,
             products[_productId].location
        );
    }

    /**
     * @dev Initializes the shipment status of a product. The function can only be called by authorized users.
     *
     * Requirements:
     * - Caller must have the AUTHORIZED_ROLE.
     * - Product should exist and not be out of stock.
     * - Product should have been shipped before.
     *
     * @param _productId The ID of the product to initialize shipment for.
     * @param _locationName The new location name where the product is stored.
     */

    // FUNCTION TO INITALIZE-SHIPMENT
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
