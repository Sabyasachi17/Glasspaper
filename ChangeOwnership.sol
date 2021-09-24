pragma solidity >=0.4.21 <0.9.0;

//Add ProductManagement ABI to allow calls
contract ProductManagement{
    struct Process{
        address manufacturer;
        string serial_number;
        string production_type;
        string creation_date;
    }

    struct Product{
        address manufacturer;
        string serial_number;
        string production_type;
        string creation_date;
        bytes32[] processes;
    }

    mapping(bytes32 => Process) public processes;
    mapping(bytes32 => Product) public products;

    function getProcess(bytes32 product_hash) public returns (bytes32[6] memory) {}
}

contract ChangeOwnership {

    enum OperationType {PROCESS, PRODUCT}
    mapping(bytes32 => address) public currentProcessOwner;
    mapping(bytes32 => address) public currentProductOwner;

    event TransferProcessOwnership(bytes32 indexed p, address indexed account);
    event TransferProductOwnership(bytes32 indexed p, address indexed account);
    ProductManagement private pm;

    constructor(address prod_contract_addr) public {
        //Just create a new auxiliary contract. We will use it to check if the part or product really exist
        pm = ProductManagement(prod_contract_addr);
    }

    function addOwnership(uint op_type, bytes32 p_hash) public returns (bool) {
        if(op_type == uint(OperationType.PROCESS)){
            address manufacturer;
            (manufacturer, , , ) = pm.processes(p_hash);
            require(currentProcessOwner[p_hash] == address(0), "Process was already registered");
            require(manufacturer == msg.sender, "Process not made by requester");
            currentProcessOwner[p_hash] = msg.sender;
            emit TransferProcessOwnership(p_hash, msg.sender);
        } else if (op_type == uint(OperationType.PRODUCT)){
            address manufacturer;
            (manufacturer, , , ) = pm.products(p_hash);
            require(currentProductOwner[p_hash] == address(0), "Product was already registered");
            require(manufacturer == msg.sender, "Product was not made by requester");
            currentProductOwner[p_hash] = msg.sender;
            emit TransferProductOwnership(p_hash, msg.sender);
        }
    }

    function changeOwnership(uint op_type, bytes32 p_hash, address to) public returns (bool) {
      //Check if the element exists and belongs to the user requesting ownership change
        if(op_type == uint(OperationType.PROCESS)){
            require(currentProcessOwner[p_hash] == msg.sender, "Process is not owned by requester");
            currentProcessOwner[p_hash] = to;
            emit TransferProcessOwnership(p_hash, to);
        } else if (op_type == uint(OperationType.PRODUCT)){
            require(currentProductOwner[p_hash] == msg.sender, "Product is not owned by requester");
            currentProductOwner[p_hash] = to;
            emit TransferProductOwnership(p_hash, to);
            //Change part ownership too
            bytes32[6] memory process_list = pm.getProcess(p_hash);
            for(uint i = 0; i < process_list.length; i++){
                currentProcessOwner[process_list[i]] = to;
                emit TransferProcessOwnership(process_list[i], to);
            }

        }
    }
}