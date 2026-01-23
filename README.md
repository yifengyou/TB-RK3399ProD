# Toybrick TB-RK3399ProD开发板

![](./images/288152853375800.png)

![](./images/288160604790600.png)

Toybrick RK3399Pro开发板是针对瑞芯微RK3399Pro芯片开发的集参考设计、芯片调试和测 试、芯片验证一体的硬件开发板，用于展示瑞芯微RK3399Pro芯片强大的多媒体接口和丰富的外
围接口，同时为开发者提供基于瑞芯微RK3399Pro芯片的硬件参考设计，使开发者不需修改或者 只需要简单修改参考设计的模块电路，就可以完成AI人工智能产品的硬件开发。

Toybrick RK3399Pro开发板支持RK3399Pro芯片的SDK开发、应用软件的开发和运行等。由 于接口齐全、设计具备较强拓展性，可应用不同使用场景、全功能验证。

---

## 相关站点

* 官网: <https://t.rock-chips.com/portal.php?mod=view&aid=4>

## 尺寸图

![](./images/3228163032300.png)

## 关键源码

U-Boot源码

```shell
git clone https://github.com/rockchip-toybrick/u-boot.git
```

Kernel源码

```shell
git clone https://github.com/rockchip-toybrick/kernel.git
```

RKBIN下载

```shell
git clone https://github.com/rockchip-toybrick/rkbin.git
```

* 工具链兼容性 Rockchip 官方提供的交叉编译工具链（如 gcc-linaro-6.3.1-2017.05-x86_64_aarch64-linux-gnu）在 Ubuntu 18.04 上测试最充分，依赖库（如
  glibc、libstdc++）版本匹配。
* 内核与 U-Boot 版本 TB-RK3399ProD 的官方内核多为 4.4 或 4.19，U-Boot 为 2017.x ～ 2022.x，这些版本在 Ubuntu 18.04 的
  GCC（7.5）、Flex/Bison、Python（2/3 兼容）环境下编译最稳定。
* NPU SDK 依赖 Rockchip 的 RKNPU SDK（如 rknpu_ddk、rknpu_runtime）通常只提供 Ubuntu 18.04 的预编译库和示例，高版本 Ubuntu 可能缺少兼容的 librga、libdrm
  或 OpenCV 版本。
* Docker / 构建脚本支持 官方 GitHub 仓库（如 rockchip-toybrick）中的 build.sh 或 Dockerfile 多基于 ubuntu:18.04 镜像。

已明确不支持 Linux 6.x 的 RK3399Pro 板型

## 适配情况

首选：Radxa ROCK Pi N10 + Armbian 24.01（Linux 6.6）

| 板型 | 厂商 | 说明 |
|------|------|------|
| TB-RK3399ProD | Toybrick | 官方仅支持到 Linux 4.19，NPU 驱动依赖旧内核 API，无法移植到 6.x |
| Orange Pi 4 Pro | Xunlong | 停留在 Linux 5.10，无 6.x 计划 |
| Khadas Edge-V Pro | Khadas | 虽为 RK3399Pro，但官方放弃维护，社区支持弱 |

RK3399Pro 开发板 Linux 6.x 支持对比（2026年）

| 开发板 | SoC | 官方 6.x 内核 | NPU 在 6.x 可用 | GPU 加速 | 推荐度 |
|--------|-----|----------------|------------------|----------|--------|
| ROCK Pi N10 | RK3399Pro | ✅ Yes (6.6) | ✅ Yes (RKNPU2) | ⚠️ fbdev only | ⭐⭐⭐⭐⭐ |
| ROC-RK3399Pro-PC | RK3399Pro | ⚠️ Experimental (6.1) | ✅（需手动集成） | ⚠️ 闭源 Mali | ⭐⭐⭐ |
| Armbian on N10 | RK3399Pro | ✅ Yes (6.6) | ✅ Yes | ⚠️ fbdev | ⭐⭐⭐⭐ |
| TB-RK3399ProD | RK3399Pro | ❌ No | ❌ No | ❌ 闭源失效 | ⭐ |







