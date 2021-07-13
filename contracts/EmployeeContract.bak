pragma experimental ABIEncoderV2;

contract EmployeeContract {
    enum Position{
        CEO,// 0
        HR, // 1
        FINC,// 2
        MKT, // 3
        CEO_SCRT,// 4
        HR_SCRT,// 5
        FINC_SCRT,// 6
        MKT_SCRT, // 7
        COSTUMER_SUPPORT // 8
    }

    struct Employee {
        string name;
        uint salary;
        bool[] approvals;
        Position position;
    }

    mapping (address => Employee) contracts;
    address[] employees;
    bool[] default_approvals = [true,true,true,true];
    bool[] default_approvals_restart = [false,false,false,false];
    event ChangeOfSalaryEvent(address _employee, uint _newSalary, uint _now);

    constructor(address[] memory _addresses, string[] memory _names, uint[] memory _salaries) public {
        contracts[_addresses[uint256(Position.CEO)]] = Employee(_names[uint256(Position.CEO)],_salaries[uint256(Position.CEO)],default_approvals,Position.CEO);
        contracts[_addresses[uint256(Position.HR)]] = Employee(_names[uint256(Position.HR)],_salaries[uint256(Position.HR)],default_approvals,Position.HR);
        contracts[_addresses[uint256(Position.FINC)]] = Employee(_names[uint256(Position.FINC)],_salaries[uint256(Position.FINC)],default_approvals,Position.FINC);
        contracts[_addresses[uint256(Position.MKT)]] = Employee(_names[uint256(Position.MKT)],_salaries[uint256(Position.MKT)],default_approvals,Position.MKT);
        for(uint i=0;i<_addresses.length;i++){
            employees.push(_addresses[i]);
        }
    }
    // ********************************************************
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
    modifier validPosition(uint256 _positionIndex) {
        require(_positionIndex >= 0 && _positionIndex <= uint256(Position.COSTUMER_SUPPORT),"The position number is not valid.");
        _;
    }
    modifier isAdmin() {
        require(
            contracts[msg.sender].position == Position.CEO ||
            contracts[msg.sender].position == Position.HR ||
            contracts[msg.sender].position == Position.FINC ||
            contracts[msg.sender].position == Position.MKT,
            "You are not admin!");
        _;
    }
    // ********************************************************
    function getEmployees() public isEmployee(msg.sender) onlyHR view returns (address[] memory) {
        return employees;
    }
    function modifySalary(address _employee, uint _newSalary) public isEmployee(msg.sender) isEmployee(_employee) onlyHR {
        contracts[_employee].salary = _newSalary;
        emit ChangeOfSalaryEvent(_employee, _newSalary, block.timestamp);
    }
    function _approveEmployeePosition(address _employee, Position _approverPosition) private validPosition(uint256(_approverPosition)) {
        contracts[_employee].approvals[uint256(_approverPosition)] = true;
    }
    function changeEmployeePosition(address _employee, uint _newPosition) public isEmployee(msg.sender) isEmployee(_employee) onlyHR validPosition(_newPosition) {
        contracts[_employee].approvals = default_approvals_restart;
        contracts[_employee].position = Position(_newPosition);
        _approveEmployeePosition(_employee, contracts[msg.sender].position);
    }
    function approveEmployeePosition(address _employee) public isEmployee(msg.sender) isEmployee(_employee) isAdmin {
        _approveEmployeePosition(_employee, contracts[msg.sender].position);
    }
    function addNewEmployee(address _employee, string memory _name, uint _salary, uint _position) public isEmployee(msg.sender) onlyHR validPosition(_position) {
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

}

