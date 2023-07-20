## 简介

本项目用于编译打包 斐讯N1 使用的 openwrt 固件，可编译 LEDE，immortalwrt master 分支和 immortalwrt 18.06-k5.4 分支。

## 说明

- .github/workflows 目录下 auto-build.yml 文件的作用是联动内核仓库实现新内核编译完成自动开始构建固件。
- 手动编译在 Actions 页面下选择 Build Openwrt 工作流，点击 Run workflow 并先择好源码仓库后单击绿色 Run workflow 按钮开始编译。编译完成后固件会自动上传至 Releases 中。
- 

## 感谢

- [P3TERX](https://p3terx.com)
- [Microsoft Azure](https://azure.microsoft.com)
- [GitHub Actions](https://github.com/features/actions)
- [OpenWrt](https://github.com/openwrt/openwrt)
- [Lean's OpenWrt](https://github.com/coolsnowwolf/lede)
- [Immortalwrt](https://github.com/immortalwrt/immortalwrt)
- [Ophub](https://github.com/ophub)
- [Flippy](https://github.com/unifreq)
- [Breakings](https://github.com/breakings)
