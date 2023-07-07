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

// File contracts/ISnapsRegistry.sol

pragma solidity ^0.8.17;

interface ISnapsRegistry {
    ///////
    /// States
    //////

    /// Snap entry aggregating one to many snap versions
    /// @param name Proposed snap name by the publisher
    /// @param description Short description of the snap
    /// @param published Externally Owned Account of the snap publisher
    /// @param authorName Self-designation of the author of the snap
    /// @param category Snap category identifier from snap category extended list (1: SECURITY, 2:MESSAGING, 3:MULTICHAIN, 4:API, 5:IDENTITY, 6:PRIVACY, 7:KEY_MANAGEMENT, 8:NOTIFICATIONS...)
    /// @param docUrl Documentation dedicated to the snap's end-users `{docUurl}/`and developers `{docUurl}/api`
    /// @param creationTime Entry registration date
    /// @param recordedVersions Listing of the released snap versions
    /// @param releasedVersions Mapping of the released snap versions for existance checking
    /// @param versions Mapping of `SnapVersion` where the key is the code's shasum
    struct Snap {
        string name;
        string description;
        address publisher;
        string authorName;
        uint256 category;
        string docUrl;
        uint256 creationTime;
        string[] recordedVersions;
        mapping(address => bool) owners;
        mapping(string => bool) areReleasedVersions;
        mapping(string => SnapVersion) versions;
    }

    /// Snap version object refering to a published release
    /// @param location location of the snap's code
    /// @param shasum sha-256 sum of the snap's code
    /// @param signature signature of the snap owner with the keccak256 of the version publisher address as digest
    /// @param changeLog description of the change in the version
    /// @param status status of the snap version
    /// @param statusChangeReason reason of the status change
    struct SnapVersion {
        string shasum;
        string location;
        string semVer;
        string changeLog;
        Status status;
        string statusChangeReason;
        address publisher;
        uint256 creationTime;
    }

    /// Snaps version status
    /// @notice `LIVE` Snap version is running live, `PAUSED` Snap version is paused because of a temporary issue, `DEPRECATED` Snap version is no more maintained and not recomended to use
    enum Status {
        LIVE,
        PAUSED,
        DEPRECATED
    }

    ///////
    /// Events
    //////
    event SnapAdded(
        uint256 snapId,
        address indexed snapPublisher,
        string name,
        string description,
        string author,
        uint256 indexed category,
        string docUrl,
        uint256 indexed creationTime
    );
    event SnapVersionAdded(
        uint256 indexed snapId,
        string indexed semVerHash,
        string indexed locationHash,
        string semVer,
        string location,
        string shasum,
        string changeLog,
        uint256 creationTime
    );
    event SnapVersionStatusChanged(
        uint256 indexed snapId,
        string indexed shasum,
        Status status,
        string reason
    );
    event SnapMetadataUpdated(
        uint256 indexed snapId,
        string name,
        string description,
        string author,
        uint256 category,
        string docUrl
    );
    event SnapOwnersChanged(address indexed snapOwner, bool isOwner);

    //////
    /// Errors
    //////
    error SnapMustBeCreated(uint256 snapId);
    error SnapVersionMustBeCreated(string shasum);
    error SnapVersionIsAlreadyCreated(string shasum);
    error ShasumAlreadyUsed(string shasum);
    error MsgSenderMustBeASnapOwner(address msgSender);
    error MsgSendersCannotBeChangedByTheirselves(address msgSender);
    error InvalidStatusRange(Status status);
    error StringFieldMustBeFilled(string field);
    error UintFieldMustBeFilled(uint256 field);

    //////
    /// Functions
    //////
    function addSnap(
        string memory snapName,
        string memory description,
        string memory author,
        uint256 category,
        string memory docUrl
    ) external returns (uint256);

    function addSnapVersion(
        uint256 snapId,
        string memory shasum,
        string memory location,
        string memory version,
        string memory changeLog
    ) external;

    function getSnap(
        uint256 snapId
    )
        external
        returns (
            string memory name,
            string memory description,
            string memory author,
            uint256 category,
            string memory docUrl,
            address publisher,
            uint256 creationTime
        );

    function getSnapVersion(
        string memory shasum
    ) external returns (SnapVersion memory);

    function getSnapVersions(
        uint256 snapId
    ) external view returns (string[] memory recordedVersions);

    function getSnapTotalSupply() external view returns (uint256 totalSupply);

    function setSnapOwners(uint256 snapId, address snapOwner) external;

    function setSnapMetadata(
        uint256 snapId,
        string memory snapName,
        string memory description,
        string memory author,
        uint256 category,
        string memory docUrl
    ) external;

    function setSnapVersionStatus(
        string memory shasum,
        Status status,
        string memory reason
    ) external;

    function isSnapAdded(uint256 snapId) external view returns (bool isAdded);

    function isSnapVersionAdded(
        string memory shasum
    ) external view returns (bool isAdded);
}

// File contracts/SnapsRegistry.sol

pragma solidity ^0.8.17;

contract SnapsRegistry is ISnapsRegistry {
    /// Snaps counter used to generate snaps' decentralized identifiers (DID) `snapId`
    using Counters for Counters.Counter;
    Counters.Counter private _snapsIndex;

    /// Contract metadata
    string public name;
    string public symbol;

    /// Snaps entries where the key is the `snapId` that is an auto increment
    mapping(uint256 => Snap) private _snaps;
    /// Lineage from snaps versions `shasum` to snaps `snapId`
    mapping(string => uint256) private _snapIdForSnapVersion;

    constructor(string memory name_, string memory symbol_) {
        name = name_;
        symbol = symbol_;
    }

    /// Record a new snap in the registry
    /// @notice Snap entry defines the concept of `snap` as a whole grouping `snap versions` that are published over time
    /// @param name_ Proposed snap name by the publisher
    /// @param description Short description of the snap
    /// @param authorName Self-designation of the author of the snap
    /// @param category Snap category identifier from snap category extended list (1: SECURITY, 2:MESSAGING, 3:MULTICHAIN, 4:API, 5:IDENTITY, 6:PRIVACY, 7:KEY_MANAGEMENT, 8:NOTIFICATIONS...)
    /// @param docUrl Documentation dedicated to the snap's end-users `{docUurl}/`and developers `{docUurl}/api`
    /// @return assignedIdentifier Identifier assigned to the new snap, usable as a Decentralized Identifier (DID)
    function addSnap(
        string memory name_,
        string memory description,
        string memory authorName,
        uint256 category,
        string memory docUrl
    ) external returns (uint256 assignedIdentifier) {
        if (bytes(name_).length == 0) revert StringFieldMustBeFilled(name_);

        _snapsIndex.increment();
        uint256 snapId = _snapsIndex.current();
        uint256 creationTime = block.timestamp;

        Snap storage newSnap = _snaps[snapId];
        newSnap.publisher = msg.sender;
        newSnap.owners[msg.sender] = true;
        newSnap.name = name_;
        newSnap.description = description;
        newSnap.authorName = authorName;
        newSnap.category = category;
        newSnap.docUrl = docUrl;
        newSnap.creationTime = creationTime;

        emit SnapAdded(
            snapId,
            msg.sender,
            name_,
            description,
            authorName,
            category,
            docUrl,
            creationTime
        );

        return snapId;
    }

    /// Record a new snap version in the registry
    /// @notice Snap version entry can be added by an owner of an existing snap
    /// @param snapId Identifier of the snap on which the version is associated
    /// @param shasum SHA-256 sum of the snap version's code. Shasum are used as the identifier of the snap version, it is usable as a Decentralized Identifier (DID)
    /// @param location Location of the snap code base
    /// @param semVer Semantic versioning of the snap
    /// @param changeLog Notable changes made to the new released snap version
    function addSnapVersion(
        uint256 snapId,
        string memory shasum,
        string memory location,
        string memory semVer,
        string memory changeLog
    ) external {
        if (!isSnapAdded(snapId)) revert SnapMustBeCreated(snapId);
        if (!_snaps[snapId].owners[msg.sender])
            revert MsgSenderMustBeASnapOwner(msg.sender);
        if (_snaps[snapId].areReleasedVersions[shasum])
            revert SnapVersionIsAlreadyCreated(shasum);
        if (_snapIdForSnapVersion[shasum] != 0)
            revert ShasumAlreadyUsed(shasum);
        if (snapId == 0) revert UintFieldMustBeFilled(snapId);
        if (bytes(shasum).length == 0) revert StringFieldMustBeFilled(shasum);
        if (bytes(location).length == 0)
            revert StringFieldMustBeFilled(location);
        if (bytes(semVer).length == 0) revert StringFieldMustBeFilled(semVer);
        if (bytes(changeLog).length == 0)
            revert StringFieldMustBeFilled(changeLog);

        Snap storage snap = _snaps[snapId];
        snap.recordedVersions.push(shasum);
        snap.areReleasedVersions[shasum] = true;
        uint256 creationTime = block.timestamp;

        SnapVersion storage newVersion = snap.versions[shasum];
        newVersion.publisher = msg.sender;
        newVersion.status = Status.LIVE;
        newVersion.shasum = shasum;
        newVersion.location = location;
        newVersion.semVer = semVer;
        newVersion.changeLog = changeLog;
        newVersion.creationTime = creationTime;

        _snapIdForSnapVersion[shasum] = snapId;

        emit SnapVersionAdded(
            snapId,
            semVer,
            location,
            semVer,
            location,
            shasum,
            changeLog,
            creationTime
        );
    }

    /// Verification if a specific snap has been added to the registry
    /// @param snapId Identifier of the snap
    /// @return isAdded Either the snap has been added or not
    function isSnapAdded(uint256 snapId) public view returns (bool isAdded) {
        return (_snaps[snapId].creationTime != 0);
    }

    /// Verification if a specific snap version has been added to the registry
    /// @param shasum Identifier of the snap version
    /// @return isAdded Either the snap has been added or not
    function isSnapVersionAdded(
        string memory shasum
    ) public view returns (bool isAdded) {
        return (_snapIdForSnapVersion[shasum] != 0);
    }

    /// Get snap entry
    /// @param snapId Identifier of the snap
    function getSnap(
        uint256 snapId
    )
        external
        view
        returns (
            string memory snapName,
            string memory description,
            string memory authorName,
            uint256 category,
            string memory docUrl,
            address publisher,
            uint256 creationTime
        )
    {
        if (!isSnapAdded(snapId)) revert SnapMustBeCreated(snapId);

        return (
            _snaps[snapId].name,
            _snaps[snapId].description,
            _snaps[snapId].authorName,
            _snaps[snapId].category,
            _snaps[snapId].docUrl,
            _snaps[snapId].publisher,
            _snaps[snapId].creationTime
        );
    }

    /// Get snap version entry
    /// @param shasum Identifier of the snap version
    function getSnapVersion(
        string memory shasum
    ) external view returns (SnapVersion memory) {
        if (!isSnapVersionAdded(shasum))
            revert SnapVersionMustBeCreated(shasum);
        uint256 snapId = _snapIdForSnapVersion[shasum];

        return _snaps[snapId].versions[shasum];
    }

    /// Get the list of shasum of the snap versions of the given snap
    /// @param snapId Identifier of the snap
    function getSnapVersions(
        uint256 snapId
    ) external view returns (string[] memory recordedVersions) {
        if (!isSnapAdded(snapId)) revert SnapMustBeCreated(snapId);

        return _snaps[snapId].recordedVersions;
    }

    /// Get the shasum of the last snap version added of the given snap
    /// @param snapId Identifier of the snap
    function getSnapLastVersion(
        uint256 snapId
    ) external view returns (string memory) {
        if (!isSnapAdded(snapId)) revert SnapMustBeCreated(snapId);
        string[] memory recordedVersions = _snaps[snapId].recordedVersions;

        return recordedVersions[recordedVersions.length - 1];
    }

    /// Get the total supply of snaps
    function getSnapTotalSupply() external view returns (uint256) {
        return _snapsIndex.current();
    }

    /// Add or remove a snap owner from a snap
    /// @param snapId Identifier of the snap
    /// @param snapOwner Address to be added or removed from the owners list
    function setSnapOwners(uint256 snapId, address snapOwner) external {
        if (!_snaps[snapId].owners[msg.sender])
            revert MsgSenderMustBeASnapOwner(msg.sender);
        if (msg.sender == snapOwner)
            revert MsgSendersCannotBeChangedByTheirselves(msg.sender);

        _snaps[snapId].owners[snapOwner] = !_snaps[snapId].owners[snapOwner];

        emit SnapOwnersChanged(snapOwner, !_snaps[snapId].owners[snapOwner]);
    }

    /// Set snap version status
    /// @param shasum Identifier of the snap version
    /// @param status New snap version status
    /// @param reason Reason of the snap status change
    function setSnapVersionStatus(
        string memory shasum,
        Status status,
        string memory reason
    ) external {
        if (!isSnapVersionAdded(shasum))
            revert SnapVersionMustBeCreated(shasum);
        uint256 snapId = _snapIdForSnapVersion[shasum];
        if (!_snaps[snapId].owners[msg.sender])
            revert MsgSenderMustBeASnapOwner(msg.sender);
        if (status > Status.DEPRECATED) revert InvalidStatusRange(status);

        _snaps[snapId].versions[shasum].status = status;
        _snaps[snapId].versions[shasum].statusChangeReason = reason;

        emit SnapVersionStatusChanged(snapId, shasum, status, reason);
    }

    /// Update snap metadata
    /// @param snapId Identifier of the snap to be changed
    /// @param name_ Proposed snap name
    /// @param description Short description of the snap
    /// @param authorName Self-designation of the author of the snap
    /// @param category Snap category identifier from snap category extended list (1: SECURITY, 2:MESSAGING, 3:MULTICHAIN, 4:API, 5:IDENTITY, 6:PRIVACY, 7:KEY_MANAGEMENT, 8:NOTIFICATIONS...)
    /// @param docUrl Documentation dedicated to the snap's end-users `{docUurl}/`and developers `{docUurl}/api`
    function setSnapMetadata(
        uint256 snapId,
        string memory name_,
        string memory description,
        string memory authorName,
        uint256 category,
        string memory docUrl
    ) external {
        if (!_snaps[snapId].owners[msg.sender])
            revert MsgSenderMustBeASnapOwner(msg.sender);
        if (bytes(name_).length != 0) _snaps[snapId].name = name_;
        if (bytes(description).length != 0)
            _snaps[snapId].description = description;
        if (bytes(authorName).length != 0)
            _snaps[snapId].authorName = authorName;
        if (bytes(docUrl).length != 0) _snaps[snapId].docUrl = docUrl;
        if (category != 0) _snaps[snapId].category = category;

        emit SnapMetadataUpdated(
            snapId,
            name_,
            description,
            authorName,
            category,
            docUrl
        );
    }
}
