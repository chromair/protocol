// SPDX-License-Identifier: BlueOak-1.0.0
pragma solidity 0.8.9;

import 'contracts/plugins/mocks/ERC20Mock.sol';
import 'contracts/plugins/assets/IYToken.sol';

contract YTokenMock is ERC20Mock, IYToken {
    uint256 _totalAssets;

    function shareValue(uint256 shares) public view returns (uint256 amount) {
     //   shares = amount * totalSupply / self._totalAssets()
        return (shares * _totalAssets) / this.totalSupply();
    }

    function mint(address recipient, uint256 amount) external {
        _mint(recipient, amount);
        _totalAssets += amount;
    }

    function burn(address sender, uint256 amount) external {
        _burn(sender, amount);
        _totalAssets -= amount;
    }
}