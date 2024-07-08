// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Roles is Ownable(msg.sender), AccessControl {
    bytes32 public constant COMPANY_OWNER_ROLE = keccak256("COMPANY_OWNER");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN");

    function grantCompanyOwnerRole(address _userAddress) public onlyOwner {
        _grantRole(COMPANY_OWNER_ROLE, _userAddress);
    }

    function revokeCompanyOwnerRole(address _userAddress) public onlyOwner {
        _revokeRole(COMPANY_OWNER_ROLE, _userAddress);
    }

    function grantAdminRole(address _admin) public onlyRole(COMPANY_OWNER_ROLE) {
        _grantRole(ADMIN_ROLE, _admin);
    }

    function revokeAdminRole(address _admin) public onlyRole(COMPANY_OWNER_ROLE) {
        _revokeRole(ADMIN_ROLE, _admin);
    }
}
