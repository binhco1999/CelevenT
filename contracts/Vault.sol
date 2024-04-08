pragma solidity <=0.8.25;

// Đảm bảo nếu trong quá trình thực thiện transaction nếu có bất cứ gì bị fail thì sẽ revert nguyên transaction đó
import "openzeppelin-solidity/contracts/token/ERC20/utils/SafeERC20.sol";

import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-solidity/contracts/access/Ownable.sol";

// Assign cái ví có quyền rút, khi user gọi thì ví này thực hiện hàm rút chứ user không có quyền rút trực tiếp (ứng dụng trong gamefi nhiều)
// Trong ABI mình chỉ để private key của ví rút, thì mình chỉ mất hết trong vault, owner sẽ có quyền set lại quyền rút cho ví khác để ngăn chặn hacker
import "openzeppelin-solidity/contracts/access/AccessControlEnumerable.sol";

contract Vault is Ownable, AccessControlEnumerable {
    // set cái vault này có thể nhận và rút token nào, sau này muốn sửa đổi chức năng rút chỉ cần đổi tên chứ không cần tạo contract mới
    IERC20 private token;
    uint256 public maxWithdrawAmount;
    bool public withdrawEnable;
    bytes32 public constant WITHDRAWER_ROLE = keccak256("WITHDRAWER_ROLE");

    function setWithdrawEnable(bool _isEnable) public onlyOwner {
        withdrawEnable = _isEnable;
    }

    function setMaxWithdrawAmount(uint256 _maxAmount) public onlyOwner {
        maxWithdrawAmount = _maxAmount;
    }

    function setToken(IERC20 _token) public onlyOwner {
        token = _token;
    }

    // Viết hàm constructor để set cho ví deploy có quyền admin role (nó sẽ set được quyền cho withdraw role)
    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    function withdraw(uint256 _amount, address _to) external onlyWithdrawer {
        require(withdrawEnable, "Withdraw is not available");
        require(_amount <= maxWithdrawAmount, "Exceed maximum amount");
        token.transfer(_to, _amount);
    }

    function deposit(uint256 _amount) external {
        require(
            token.balanceOf(msg.sender) >= _amount,
            "Insufficient account balance"
        );
        SafeERC20.safeTransferFrom(token, msg.sender, address(this), _amount);
    }

    modifier onlyWithdrawer() {
        require(
            owner() == _msgSender() || hasRole(WITHDRAWER_ROLE, _msgSender()),
            "Caller is not a withdrawer"
        );
        _;
    }
}
