pragma solidity >=0.4.21 <0.9.0;

contract ProductManagement {
    struct Process{
        address manufacturer;
        string serial_number;
        string process_type;
        string creation_date;
        //string long_lat;
    }
    struct Product{
        address manufacturer;
        string serial_number;
        string product_type;
        string creation_date;
        bytes32[] processes;
    }

    mapping(bytes32 => Process) public processes;
    mapping(bytes32 => Product) public products;
    event Processhmade(string, string , string );
    event processhash(bytes32);
    constructor() public {
    }

    function concatenateInfoAndHash(address a1, string memory s1, string memory s2, string memory s3) public pure  returns (bytes32){
        //First, get all values as bytes
        /*bytes20 b_a1 = bytes20(a1);
        bytes memory b_s1 = bytes(s1);
        bytes memory b_s2 = bytes(s2);
        bytes memory b_s3 = bytes(s3);

        //Then calculate and reserve a space for the full string
        string memory s_full = new string(b_a1.length + b_s1.length + b_s2.length + b_s3.length);
        bytes memory b_full = bytes(s_full);
        uint j = 0;
        uint i;
        for(i = 0; i < b_a1.length; i++){
            b_full[j++] = b_a1[i];
        }
        for(i = 0; i < b_s1.length; i++){
            b_full[j++] = b_s1[i];
        }
        for(i = 0; i < b_s2.length; i++){
            b_full[j++] = b_s2[i];
        }
        for(i = 0; i < b_s3.length; i++){
            b_full[j++] = b_s3[i];
        }

        //Hash the result and return
        return keccak256(b_full);
    */
    return keccak256(abi.encodePacked(a1,s1,s2,s3));
    
    }

    function buildProcess(address manuf,string memory serial_number, string memory process_type, string memory creation_date) public returns (bytes32){
        //Create hash for data and check if it exists. If it doesn't, create the part and return the ID to the user
        bytes32 process_hash = concatenateInfoAndHash(manuf, serial_number, process_type, creation_date);
        
       // require(processes[process_hash].manufacturer == address(0), "Process ID already used");

        Process memory new_process = Process(manuf, serial_number, process_type, creation_date);
        processes[process_hash] = new_process;
        emit processhash(process_hash);
        return process_hash;
    }

    function buildProduct(string memory serial_number, string memory product_type, string memory creation_date, bytes32[] memory process_array) public returns (bytes32){
        //Check if all the parts exist, hash values and add to product mapping.
        uint i;
        for(i = 0;i < process_array.length; i++){
            require(processes[process_array[i]].manufacturer != address(0), "Inexistent process used on product");
        }

        //Create hash for data and check if exists. If it doesn't, create the part and return the ID to the user
        bytes32 product_hash = concatenateInfoAndHash(msg.sender, serial_number, product_type, creation_date);
        
        require(products[product_hash].manufacturer == address(0), "Product ID already used");

        Product memory new_product = Product(msg.sender, serial_number, product_type, creation_date, process_array);
        products[product_hash] = new_product;
        return product_hash;
    }

    function getProcess(bytes32 product_hash) public view returns (bytes32[] memory){
        //The automatic getter does not return arrays, so lets create a function for that
        require(products[product_hash].manufacturer != address(0), "Product inexistent");
        return products[product_hash].processes;
    }
}