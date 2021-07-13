pragma experimental ABIEncoderV2;
pragma solidity ^0.5.16;

contract EmployeeContract {
    uint balance;
    bool internal locked;

    enum Position{CEO,HR,FINC,MKT,CEO_SCRT,HR_SCRT,FINC_SCRT,MKT_SCRT,COSTUMER_SUPPORT}
    struct Employee {
        string name;
        uint salary;
        bool[] approvals;
        Position position;
    }
    mapping (address => Employee) contracts;
    bool[] default_approvals = [true,true,true,true];
    bool[] default_approvals_restart = [false,false,false,false];
    address[] employees;
    event Depositbalance(address _senderAddress, uint _balance, uint _timestamp);
    event ChangeOfSalaryEvent(address _employee, uint _newSalary, uint _now);
    event SentbalanceFail(address _receiverAddress, uint _balance, uint _timestamp);
    event DeliverPayroll(bool _complete, uint totalAmount, uint _timestamp);
    event Withdrawbalance(address _receiverAddress, uint _balance, uint _timestamp);


    constructor(address[] memory _addresses, string[] memory _names, uint[] memory _salaries) public {
        contracts[_addresses[uint256(Position.CEO)]] = Employee(_names[uint256(Position.CEO)],_salaries[uint256(Position.CEO)],default_approvals,Position.CEO);
        contracts[_addresses[uint256(Position.HR)]] = Employee(_names[uint256(Position.HR)],_salaries[uint256(Position.HR)],default_approvals,Position.HR);
        contracts[_addresses[uint256(Position.FINC)]] = Employee(_names[uint256(Position.FINC)],_salaries[uint256(Position.FINC)],default_approvals,Position.FINC);
        contracts[_addresses[uint256(Position.MKT)]] = Employee(_names[uint256(Position.MKT)],_salaries[uint256(Position.MKT)],default_approvals,Position.MKT);
        for(uint i=0;i<_addresses.length;i++){
            employees.push(_addresses[i]);
        }
    }

    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }

    modifier isEmployee(address _employee) {
        bool exists = false;
        for(uint i=0;i<employees.length;i++){
            if(employees[i] == _employee){
                exists = true;
            }
        }
        require(exists,"Employee doesn't exist!");
        _;
    }
    modifier onlyHR() {
        require(contracts[msg.sender].position == Position.HR, "You are not the HR!");
        _;
    }

    modifier onlyFN() {
        require(contracts[msg.sender].position == Position.FINC, "You are not authorize");
        _;
    }

    modifier isAdmin() {
        require(uint256(contracts[msg.sender].position) <= 3, "You are not administrators");
        _;
    }

    modifier validPosition(uint256 _positionIndex) {
        require(_positionIndex >= 0 && _positionIndex <= uint256(Position.COSTUMER_SUPPORT));
        _;
    }

    modifier sufficientBalance() {
        require(getGrandTotal() <= balance, "You do not have sufficient balance for all employees");
        _;
    }


    function modifySalary(address _employee, uint _newSalary) public isEmployee(msg.sender) onlyHR {
        contracts[_employee].salary = _newSalary;
        emit ChangeOfSalaryEvent(_employee, _newSalary, block.timestamp);
    }
    function getEmployees() public isEmployee(msg.sender) onlyHR view returns (address[] memory) {
        return employees;
    }
    function _approveEmployeePosition(address _employee, Position _approverPosition) private validPosition(uint256(_approverPosition)) {
        contracts[_employee].approvals[uint256(_approverPosition)] = true;
    }
    function changeEmployeePosition(address _employee, uint _newPosition) public isEmployee(msg.sender) isEmployee(_employee) onlyHR validPosition(uint256(_newPosition)) {
        contracts[_employee].approvals = default_approvals_restart;
        contracts[_employee].position = Position(_newPosition);
        _approveEmployeePosition(_employee, contracts[msg.sender].position);
    }
    function approveEmployeePosition(address _employee) public isEmployee(msg.sender) isEmployee(_employee) isAdmin {
        _approveEmployeePosition(_employee, contracts[msg.sender].position);
    }
    function addNewEmployee(address _employee, string memory _name, uint _salary, uint _position) public isEmployee(msg.sender) onlyHR validPosition(uint256(_position)) {
        contracts[_employee] = Employee(_name,_salary,default_approvals_restart,Position(_position));
        employees.push(_employee);
        _approveEmployeePosition(_employee, contracts[msg.sender].position);
    }
    function getEmployeesInfo() public isEmployee(msg.sender) onlyHR view returns (Employee[] memory) {
        Employee[] memory _employees = new Employee[](employees.length);
        for(uint i=0;i<employees.length;i++){
            _employees[i] = contracts[employees[i]];
        }
        return _employees;
    } 

    function deposit() public payable {
        balance += msg.value;
        emit Depositbalance(msg.sender, msg.value, block.timestamp);
    }

 
    function getGrandTotal() public isEmployee(msg.sender) onlyFN view returns (uint) {
        uint totalSalary = 0;
        for (uint i = 0; i < employees.length; i++) {
            totalSalary += contracts[employees[i]].salary;
        }
        return totalSalary;
    }

   function sendSalary(address payable _to, uint _salary) public payable {
        bool sentStatus = _to.send(_salary);
        if (!sentStatus) {
            emit SentbalanceFail(_to, _salary, block.timestamp);
        }
    }


    function sendPayroll() public payable isEmployee(msg.sender) onlyFN sufficientBalance noReentrant {
       for (uint i = 0; i < employees.length; i++) {
           address payable acc = address(uint160(employees[i]));
           sendSalary(acc, contracts[employees[i]].salary);
           balance -= contracts[employees[i]].salary;
       }
       emit DeliverPayroll(true, getGrandTotal(), block.timestamp);
    }



}
