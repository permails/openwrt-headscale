#
# Copyright (C) 2026 OpenWrt.org
#
# This is free software, licensed under the BSD 3-Clause License.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=headscale
PKG_VERSION:=0.29.3
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/juanfont/headscale/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=skip

PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=permails <logo@permails.com>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1

GO_PKG:=github.com/juanfont/headscale
GO_PKG_BUILD_PKG:=github.com/juanfont/headscale/cmd/headscale
GO_PKG_LDFLAGS_X:=\
	github.com/juanfont/headscale/hscontrol/types.Version=v$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/headscale
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=VPN
  TITLE:=Open source, self-hosted implementation of the Tailscale control server
  URL:=https://github.com/juanfont/headscale
  DEPENDS:=$(GO_ARCH_DEPENDS) +ca-bundle
endef

define Package/headscale/description
  Headscale is an open-source, self-hosted implementation of the Tailscale
  control server. It allows you to run your own Tailscale-compatible coordination server.
endef

define Package/headscale/conffiles
/etc/config/headscale
/etc/headscale/acl.hujson
/etc/headscale/db.sqlite
/etc/headscale/noise_private.key
/etc/headscale/derp_server_private.key
endef

define Package/headscale/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))

	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/headscale $(1)/usr/bin/

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/headscale.init $(1)/etc/init.d/headscale

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/headscale.config $(1)/etc/config/headscale

	$(INSTALL_DIR) $(1)/usr/share/headscale
	$(INSTALL_BIN) ./files/headscale.sh $(1)/usr/share/headscale/headscale.sh

	$(INSTALL_DIR) $(1)/etc/headscale
	$(INSTALL_DIR) $(1)/var/run/headscale
	$(INSTALL_DIR) $(1)/var/log/headscale
endef

$(eval $(call GoPackage,headscale))
$(eval $(call BuildPackage,headscale))
