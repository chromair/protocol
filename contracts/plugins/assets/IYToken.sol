     //   shares = amount * totalSupply / self._totalAssets()

interface IYToken {
    function shareValue(uint256) external view returns (uint256);
}