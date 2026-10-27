# SPDX-License-Identifier: Apache-2.0

include $(TOPDIR)/rules.mk

LUCI_TITLE:=Minimal graphite and mint theme for LuCI
LUCI_DEPENDS:=+luci-base
PKG_VERSION:=0.1.0
PKG_RELEASE:=6
PKG_LICENSE:=Apache-2.0

define Package/luci-theme-mavxa/postrm
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || {
	uci -q delete luci.themes.Mavxa
	uci commit luci
}
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
