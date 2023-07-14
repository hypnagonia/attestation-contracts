/**
 *Submitted for verification at goerli.lineascan.build on 2023-06-08
*/

// Sources flattened with hardhat v2.14.1 https://hardhat.org

// File @openzeppelin/contracts/utils/Counters.sol@v4.9.0

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}


// File contracts/ISnapsAuditTrail.sol

pragma solidity ^0.8.17;

interface ISnapsAuditTrail {

  /// Snap Audit entry describing potential security risks and non compliance with snap guidelines
  /// @param shasum SHA-256 sum of the snap code
  /// @param risk Assessed risk of the snap security
  /// @param isCompliant Assessed compliance with snap guidelines, such as naming convention, user interface guideline etc.
  /// @param log Short description of the audit result
  /// @param reportURI URI of the full audit report (Snaps Audit JSON format)
  /// @param creationTime Snap entry registration date
  struct SnapAudit {
    address auditor;
    string shasum;
    Risk risk;
    bool isCompliant;
    string log;
    string reportURI;
    uint256 creationTime;
  }

  enum Risk { SEVERE, MAJOR, MINOR, SAFE }

  ///////
  /// Events
  //////
  event AuditAdded(string indexed shasumHash, address indexed auditor, uint256 indexed auditId, string checksum, Risk risk, bool isCompliant, string log, string reportURI);
  event AuditMetadataUpdated(uint256 indexed auditId, address indexed auditor, string indexed shasumHash, string log, string reportURI);
  //////
  /// Errors
  //////  
  error AuditMustExist(uint256 auditId);
  error AuditAlreadyCreated(address auditor, string shasum);
  error MsgSenderMustBeAuditor(address msgSender);
  error FieldMustBeFilled(string field);
  error UintFieldMustBeFilled(uint256 field);
  error InvalidRiskRange(Risk risk);

  //////
  /// Functions
  //////
  function addAudit(string memory shasum, Risk risk, bool isCompliant, string memory log, string memory reportURI) external returns (uint256 auditId);

  function getAudit(uint256 auditId) external returns (SnapAudit memory);

  function getSnapVersionAudits(string memory shasum) external returns (SnapAudit[] memory);

  function getTotalAuditsForSnapVersion(string memory shasum) external view returns (uint256);

  function getAuditorAudits(address auditor) external view returns (SnapAudit[] memory);

  function setAuditMetadata(uint256 auditId, string memory log, string memory reportURI) external;

}


// File contracts/SnapsAuditTrail.sol

pragma solidity ^0.8.17;
contract SnapsAuditTrail is ISnapsAuditTrail {

  /// Aditos counter used to generate audits identifiers `auditId` as a decentralized identifiers (DID) 
  using Counters for Counters.Counter;
  Counters.Counter public auditsIndex;

  // contract metadata
  string public name;
  string public symbol;

  /// Audits entries where the key is the `auditId` auto incremented for each audit
  mapping(uint256 => SnapAudit) private _audits;
  /// Lineage from snaps versions `shasum` to audits `auditId`
  mapping(string => uint256[]) private _auditsForSnapVersion;
  /// List of audits for an auditor
  mapping(address => uint256[]) private _auditsForAuditor;
  /// Keep track if snap versions have already been audited by auditors
  mapping(address => mapping(string => bool)) private _areSnapVersionsAuditedByAuditor;


  constructor(string memory name_, string memory symbol_) {
    name = name_;
    symbol = symbol_;
  }

  /// Publish a new snap audit in the audit trail
  /// @param shasum SHA-256 sum of the snap version's code. Shasum are used as the identifier of the snap version
  /// @param risk Assessed risk of the snap security
  /// @param isCompliant Assessed compliance with snap guidelines, such as naming convention, user interface guideline etc.
  /// @param log Short description of the audit result
  /// @param reportURI URI of the full audit report (Snaps Audit JSON format)
  function addAudit(string memory shasum, Risk risk, bool isCompliant, string memory log, string memory reportURI) external returns (uint256) {
    if (bytes(shasum).length == 0) revert FieldMustBeFilled(shasum);
    if (bytes(log).length == 0) revert FieldMustBeFilled(log);
    if (bytes(reportURI).length == 0) revert FieldMustBeFilled(reportURI);
    if (risk > Risk.SAFE) revert InvalidRiskRange(risk);
    if (_areSnapVersionsAuditedByAuditor[msg.sender][shasum]) revert AuditAlreadyCreated(msg.sender, shasum);

    auditsIndex.increment();
    uint256 auditId = auditsIndex.current();
    uint256 creationTime = block.timestamp;

    SnapAudit storage newAudit = _audits[auditId];
    newAudit.auditor = msg.sender;
    newAudit.shasum = shasum;
    newAudit.risk = risk;
    newAudit.isCompliant = isCompliant;
    newAudit.log = log;
    newAudit.reportURI = reportURI;
    newAudit.creationTime = creationTime;

    _auditsForSnapVersion[shasum].push(auditId);
    _auditsForAuditor[msg.sender].push(auditId);
    _areSnapVersionsAuditedByAuditor[msg.sender][shasum] = true;

    emit AuditAdded(shasum, msg.sender, auditId, shasum, risk, isCompliant, log, reportURI);

    return auditId;
  }

  /// Verification if a specific audit has been added to the audit trail
  /// @param auditId Identifier of the audit
  /// @return isAdded Either the snap has been added or not
  function _auditExists(uint256 auditId) private view returns (bool isAdded) {
    return (_audits[auditId].creationTime != 0);
  }


  /// Get audit entry
  /// @param auditId Identifier of the audit
  function getAudit(uint256 auditId) external view returns (SnapAudit memory) {
    if (!_auditExists(auditId)) revert AuditMustExist(auditId);

    return _audits[auditId];
  }


  /// Get number of audits existing for a snap version
  /// @param shasum Snap version identifier
  function getTotalAuditsForSnapVersion(string memory shasum) external view returns (uint256) {
    return _auditsForSnapVersion[shasum].length;
  }


  /// Get audits published for a snap version
  /// @param shasum Snap version identifier
  /// @return snapAudits List of snap audits
  function getSnapVersionAudits(string memory shasum) external view returns (SnapAudit[] memory) {
    uint256 [] memory auditsIds = _auditsForSnapVersion[shasum];
    SnapAudit[] memory snapAudits = new SnapAudit[](auditsIds.length);

    for (uint i = 0; i < auditsIds.length; i++) {
      SnapAudit memory snapAudit = _audits[auditsIds[i]];
      snapAudits[i] = snapAudit;
    }
    return snapAudits;
  }


  /// Get audits published by an auditor
  /// @param auditor Address of the auditor
  /// @return snapAudits List of snap audits
  function getAuditorAudits(address auditor) external view returns (SnapAudit[] memory) {
    uint256 [] memory auditsIds = _auditsForAuditor[auditor];
    SnapAudit[] memory snapAudits = new SnapAudit[](auditsIds.length);

    for (uint i = 0; i < auditsIds.length; i++) {
      SnapAudit memory snapAudit = _audits[auditsIds[i]];
      snapAudits[i] = snapAudit;
    }
    return snapAudits;
  }


  /// Update audit metadata
  /// @param auditId Identifier of the audit to be changed
  /// @param log Short description of the audit result
  /// @param reportURI URI of the full audit report (Snaps Audit JSON format)
  function setAuditMetadata(uint256 auditId, string memory log, string memory reportURI) external {
    if (!_auditExists(auditId)) revert AuditMustExist(auditId);
    if (msg.sender != _audits[auditId].auditor) revert MsgSenderMustBeAuditor(msg.sender);
    if (bytes(log).length == 0) revert FieldMustBeFilled(log);
    if (bytes(reportURI).length == 0) revert FieldMustBeFilled(reportURI);

    _audits[auditId].log = log;
    _audits[auditId].reportURI = reportURI;

    emit AuditMetadataUpdated(auditId, msg.sender, _audits[auditId].shasum, log, reportURI);
  }

}