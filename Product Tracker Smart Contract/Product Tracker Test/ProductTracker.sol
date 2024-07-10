// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol"; // Include Roles library

// import "./Roles."; // Import your Roles contract
import "./ValidationLibrary.sol"; // Import your validation library (if applicable)


/**
 * @title ProductTracker
 * This contract allows tracking of products in a supply chain with various attributes and location details.
 */
contract ProductTracker is Ownable(msg.sender), AccessControl {
    bytes32 public constant COMPANY_OWNER_ROLE = keccak256("COMPANY_OWNER");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN");

    // state variable
    uint256 public nextProductId = 1;

    struct Product {
        uint256 productId;
        string productType;
        string brandName;
        string productName;
        uint256 quantity;
        uint256 productionDate;
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
    mapping(uint256 => address) public productGenerator;
    /// mapping for authorizedUsers is substituted by AccessControl.sol from openzeppelin
    // mapping(address => bool) public authorizedUsers;

    // Events
    event ProductGenerated(
        uint256 indexed productId,
        string productType,
        string brandName,
        string productName,
        uint256 quantity,
        address indexed generator,
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
            products[_productId].location.shipped == false,
            "Product has been shipped"
        );
        require(
            products[_productId].productId == _productId,
            "Product does not exist"
        );
        require(products[_productId].quantity != 0, "Product is out of stock");
        _;
    }

    modifier onlyCompanyOwner() {
        require(hasRole(COMPANY_OWNER_ROLE, msg.sender), "User not the company owner");
        _;
    }

    modifier onlyAdmin() {
        require(hasRole(ADMIN_ROLE, msg.sender), "User not admin");
        _;
    }

    modifier validateProductDetails(
        string memory _productType,
        string memory _productName,
        string memory _brandName,
        uint256 _quantity
    ) {
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
        _; // The rest of the function code follows here
    }

    modifier checkGenerator(uint256 _productId) {
        require(
            msg.sender == productGenerator[_productId],
            "Only the product generator can call this function"
        );
        _;
    }
    

    function authorizeCompanyOwner(address _userAddress) public onlyOwner {
        _grantRole(COMPANY_OWNER_ROLE, _userAddress);
    }
    
    function revokeCompanyOwner(address _userAddress) public onlyOwner {
        _revokeRole(COMPANY_OWNER_ROLE, _userAddress);
    }

    function grantAdminRole(address _admin)
        public
        onlyRole(COMPANY_OWNER_ROLE)
    {
        _grantRole(ADMIN_ROLE, _admin);
    }

    function revokeAdminRole(address _admin)
        public
        onlyRole(COMPANY_OWNER_ROLE)
    {
        _revokeRole(ADMIN_ROLE, _admin);
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
        uint256 _quantity,
        string memory _locationName, // Optional location name
        string memory _custodian,
        bool _shipped
    )
        public
        onlyCompanyOwner onlyAdmin
        validateProductDetails(
            _productType,
            _productName,
            _brandName,
            _quantity
        )
    {
        // Validate product details directly within the function
        uint256 _productId = nextProductId;

        products[_productId] = Product(
            _productId,
            _productType,
            _brandName,
            _productName,
            _quantity,
            block.timestamp,
            Location({
                name: _locationName,
                custodian: _custodian,
                shipped: _shipped,
                departure: _shipped ? block.timestamp : 0,
                arrived: false, // Set default values for other fields
                arrival: 0
            })
        );

        productGenerator[nextProductId] = msg.sender;

        emit ProductGenerated(
            _productId,
            _productType,
            _brandName,
            _productName,
            _quantity,
            msg.sender,
            products[_productId].location
        );

        nextProductId++;
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
        productExisted(_productId) onlyCompanyOwner onlyAdmin
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
