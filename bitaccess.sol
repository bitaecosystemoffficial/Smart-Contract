/**
 *Submitted for verification at BscScan.com on 2024-10-05
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

library Address {
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 9; // Consider if this is intentional, as most tokens use 18 decimals.
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        _transfer(sender, recipient, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}

// Add ReentrancyGuard
contract ReentrancyGuard {
    uint256 private _guardCounter;

    constructor() {
        _guardCounter = 1;
    }

    modifier nonReentrant() {
        require(_guardCounter == 1, "ReentrancyGuard: reentrant call");
        _guardCounter = 2;
        _;
        _guardCounter = 1;
    }
}

contract BITACCESSTOKEN is ERC20, Ownable, ReentrancyGuard {
    using Address for address payable;

    bool public tradingEnabled;
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    mapping(address => bool) private _isExcludedFromFees;

    uint256 public feeOnBuy;
    uint256 public feeOnSell;
    uint256 public feeOnTransfer;

    uint256 public maxBuyFee;
    uint256 public maxSellFee;
    uint256 public totalFeeLimit;

    address public feeReceiver;
    uint256 public swapTokensAtAmount;
    bool private swapping;
    bool public swapEnabled;

    // Airdrop variables
    uint256 public constant AIRDROP_TOTAL = 10_000_000 * (10 ** 9);
    uint256 public constant AIRDROP_AMOUNT = 1_000 * (10 ** 9);
    uint256 public totalAirdropped;
    mapping(address => bool) public hasClaimedAirdrop;
    address public airdropWallet;

    // Public wallets for various purposes
    struct Wallets {
        address presale;
        address liquidityDEX;
        address liquidityCEX;
        address marketing;
        address p2p;
        address managementTeam;
        address foundation;
        address emergencyFund;
        address projectDevelopment;
        address companyReserved;
        address staking;
    }

    Wallets public wallets;

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event SwapAndSendFee(uint256 tokensSwapped, uint256 bnbSend);
    event SwapTokensAtAmountUpdated(uint256 swapTokensAtAmount);
    event FeeReceiverChanged(address feeReceiver);
    event TradingEnabled(bool tradingEnabled);
    event BuyFeeUpdated(uint256 newFee);
    event SellFeeUpdated(uint256 newFee);
    event AirdropClaimed(address indexed recipient, uint256 amount);
    event AirdropWalletChanged(address indexed newWallet);
    event WalletAssigned(string walletType, address walletAddress);
    event SwapAndSendFeeFailed(uint256 tokensSwapped); // Added event for swap failure

    constructor() ERC20("Bit Access", "BIT") {
        address router;
        address pinkLock;

        if (block.chainid == 56) {
            router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
            pinkLock = 0x407993575c91ce7643a4d4cCACc9A98c36eE1BBE;
        } else if (block.chainid == 97) {
            router = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
            pinkLock = 0x5E5b9bE5fd939c578ABE5800a90C566eeEbA44a5;
        } else if (block.chainid == 1 || block.chainid == 5) {
            router = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
            pinkLock = 0x71B5759d73262FBb223956913ecF4ecC51057641;
        } else {
            revert("Unsupported network");
        }

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(router);
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;

        _approve(address(this), address(uniswapV2Router), type(uint256).max);

        feeOnBuy = 3;
        feeOnSell = 3;
        feeOnTransfer = 0;
        maxBuyFee = 5;
        maxSellFee = 5;
        totalFeeLimit = 10;

        feeReceiver = 0x3ce97358eb2da745123A5832E005e3eeeea61E52;

        _isExcludedFromFees[owner()] = true;
        _isExcludedFromFees[address(0xdead)] = true;
        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[pinkLock] = true;

        _mint(owner(), 1e11 * (10 ** decimals()));
        swapTokensAtAmount = totalSupply() / 5_000;
        swapEnabled = false;

        airdropWallet = owner(); // Default to the owner
    }

    receive() external payable {}

    function creator() public pure returns (string memory) {
        return "x.com/bitaecosystem";
    }

    function claimStuckTokens(address token) external onlyOwner {
        require(token != address(this), "BIT: Owner cannot claim contract's balance of its own tokens");
        if (token == address(0)) {
            payable(msg.sender).sendValue(address(this).balance);
        } else {
            IERC20(token).transfer(msg.sender, IERC20(token).balanceOf(address(this)));
        }
    }

    function claimStuckBNB() external onlyOwner {
        uint256 contractBalance = address(this).balance;
        require(contractBalance > 0, "BIT: No BNB to claim");
        payable(owner()).sendValue(contractBalance);
    }

    function excludeFromFees(address account, bool excluded) external onlyOwner {
        _isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }

    function isExcludedFromFees(address account) public view returns (bool) {
        return _isExcludedFromFees[account];
    }

    function changeFeeReceiver(address _feeReceiver) external onlyOwner {
        require(_feeReceiver != address(0), "BIT: Fee receiver cannot be the zero address");
        feeReceiver = _feeReceiver;
        emit FeeReceiverChanged(feeReceiver);
    }

    function setAirdropWallet(address _airdropWallet) external onlyOwner {
        require(_airdropWallet != address(0), "BIT: New airdrop wallet cannot be the zero address");
        airdropWallet = _airdropWallet;
        emit AirdropWalletChanged(_airdropWallet);
    }

    function assignWallets(
        address _presaleWallet,
        address _liquidityDEXWallet,
        address _liquidityCEXWallet,
        address _marketingWallet,
        address _p2pWallet,
        address _managementTeamWallet,
        address _foundationWallet,
        address _emergencyFundWallet,
        address _projectDevelopmentWallet,
        address _companyReservedWallet,
        address _stakingWallet
    ) external onlyOwner {
        wallets.presale = _presaleWallet;
        wallets.liquidityDEX = _liquidityDEXWallet;
        wallets.liquidityCEX = _liquidityCEXWallet;
        wallets.marketing = _marketingWallet;
        wallets.p2p = _p2pWallet;
        wallets.managementTeam = _managementTeamWallet;
        wallets.foundation = _foundationWallet;
        wallets.emergencyFund = _emergencyFundWallet;
        wallets.projectDevelopment = _projectDevelopmentWallet;
        wallets.companyReserved = _companyReservedWallet;
        wallets.staking = _stakingWallet;

        emit WalletAssigned("Presale", _presaleWallet);
        emit WalletAssigned("Liquidity DEX", _liquidityDEXWallet);
        emit WalletAssigned("Liquidity CEX", _liquidityCEXWallet);
        emit WalletAssigned("Marketing", _marketingWallet);
        emit WalletAssigned("P2P", _p2pWallet);
        emit WalletAssigned("Management Team", _managementTeamWallet);
        emit WalletAssigned("Foundation", _foundationWallet);
        emit WalletAssigned("Emergency Fund", _emergencyFundWallet);
        emit WalletAssigned("Project Development", _projectDevelopmentWallet);
        emit WalletAssigned("Company Reserved", _companyReservedWallet);
        emit WalletAssigned("Staking", _stakingWallet);
    }

    function enableTrading() external onlyOwner {
        require(!tradingEnabled, "BIT: Trading already enabled.");
        tradingEnabled = true;
        swapEnabled = true;
        emit TradingEnabled(tradingEnabled);
    }

    function setSwapTokensAtAmount(uint256 newAmount, bool _swapEnabled) external onlyOwner {
        require(newAmount > totalSupply() / 1_000_000, "BIT: SwapTokensAtAmount must be greater than 0.0001% of total supply");
        swapTokensAtAmount = newAmount;
        swapEnabled = _swapEnabled;
        emit SwapTokensAtAmountUpdated(swapTokensAtAmount);
    }

    function setBuyFee(uint256 newBuyFee) external onlyOwner {
        require(newBuyFee <= maxBuyFee, "BIT: Buy fee exceeds maximum allowed");
        require(newBuyFee + feeOnSell <= totalFeeLimit, "BIT: Total fee limit exceeded");
        feeOnBuy = newBuyFee;
        emit BuyFeeUpdated(newBuyFee);
    }

    function setSellFee(uint256 newSellFee) external onlyOwner {
        require(newSellFee <= maxSellFee, "BIT: Sell fee exceeds maximum allowed");
        require(feeOnBuy + newSellFee <= totalFeeLimit, "BIT: Total fee limit exceeded");
        feeOnSell = newSellFee;
        emit SellFeeUpdated(newSellFee);
    }

    function adjustFees(uint256 newBuyFee, uint256 newSellFee) external onlyOwner {
        require(newBuyFee <= maxBuyFee, "BIT: Buy fee exceeds maximum allowed");
        require(newSellFee <= maxSellFee, "BIT: Sell fee exceeds maximum allowed");
        require(newBuyFee + newSellFee <= totalFeeLimit, "BIT: Total fee limit exceeded");

        feeOnBuy = newBuyFee;
        feeOnSell = newSellFee;

        emit BuyFeeUpdated(newBuyFee);
        emit SellFeeUpdated(newSellFee);
    }

    function claimAirdrop() external nonReentrant {
        require(!hasClaimedAirdrop[msg.sender], "BIT: Airdrop already claimed.");
        require(totalAirdropped + AIRDROP_AMOUNT <= AIRDROP_TOTAL, "BIT: Airdrop limit exceeded.");

        hasClaimedAirdrop[msg.sender] = true;
        totalAirdropped += AIRDROP_AMOUNT;

        _mint(airdropWallet, AIRDROP_AMOUNT);

        emit AirdropClaimed(msg.sender, AIRDROP_AMOUNT);
    }

    function _transfer(address from, address to, uint256 amount) internal override {
        require(from != address(0), "BIT: transfer from the zero address");
        require(to != address(0), "BIT: transfer to the zero address");
        require(tradingEnabled || _isExcludedFromFees[from] || _isExcludedFromFees[to], "BIT: Trading not yet enabled!");

        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if (canSwap &&
            !swapping &&
            to == uniswapV2Pair &&
            (feeOnBuy + feeOnSell > 0) &&
            !_isExcludedFromFees[from] &&
            swapEnabled
        ) {
            swapping = true;
            swapAndSendFee(contractTokenBalance);
            swapping = false;
        }

        uint256 _totalFees = _isExcludedFromFees[from] || _isExcludedFromFees[to] || swapping ? 0 : (from == uniswapV2Pair ? feeOnBuy : (to == uniswapV2Pair ? feeOnSell : feeOnTransfer));

        if (_totalFees > 0) {
            uint256 fees = (amount * _totalFees) / 100;
            amount -= fees;
            super._transfer(from, address(this), fees);
        }

        super._transfer(from, to, amount);
    }

    function swapAndSendFee(uint256 tokenAmount) private nonReentrant {
        uint256 initialBalance = address(this).balance;
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        try uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        ) {
            uint256 newBalance = address(this).balance - initialBalance;
            if (newBalance > 0) {
                payable(feeReceiver).sendValue(newBalance);
                emit SwapAndSendFee(tokenAmount, newBalance);
            }
        } catch {
            emit SwapAndSendFeeFailed(tokenAmount); // Emit an event instead of reverting
        }
    }

    function burn(uint256 amount) external onlyOwner {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) external onlyOwner {
        uint256 currentAllowance = allowance(account, _msgSender());
        require(currentAllowance >= amount, "ERC20: burn amount exceeds allowance");
        unchecked {
            _approve(account, _msgSender(), currentAllowance - amount);
        }
        _burn(account, amount);
    }
}