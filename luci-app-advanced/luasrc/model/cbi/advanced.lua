local e=require"nixio.fs"
local t=require"luci.sys"
local t=luci.model.uci.cursor()
m=Map("advanced",translate("高级进阶设置"),translate("<font color=\"Red\"><strong>配置文档是直接编辑的除非你知道自己在干什么，否则请不要轻易修改这些配置文档。配置不正确可能会导致不能开机等错误。</strong></font><br/>"))
m.apply_on_parse=true
s=m:section(TypedSection,"advanced")
s.anonymous=true
s:tab("base",translate("Basic Settings"))
o=s:taboption("base",Flag,"usb3_disable",translate("关闭USB3.0"),translate("勾选以关闭USB3.0，降低2.4G无线干扰。"))
o.default=0

o=s:taboption("base",ListValue,"lan2wan",translate("LAN改WAN"),translate("选择将其中一个LAN口改设为WAN口，以使用多线接入。"))
o:value("none",translate("当前模式"))
o:value("1",translate("LAN1"))
o:value("0",translate("LAN2"))
o:value("2",translate("LAN3"))
o:value("factory",translate("默认状态"))
o.default="none"

rollbacktime=t:get("luci","apply","rollback")
o=s:taboption("base",Value,"rollback",translate("超时时间"),translate("设置LUCI超时回滚时间，默认30秒。"))
o.datatypes="and(uinteger,min(20))"
o.default=rollbacktime

o=s:taboption("base",ListValue,"webshell",translate("WebShell"),translate("选择要使用的WebShell服务"))
o:value("ttyd",translate("ttyd"))
o:value("shellinabox",translate("shellinabox"))
o.default="ttyd"

o=s:taboption("base",ListValue,"route_mode",translate("运行模式"),translate("AP模式：请通过WAN网口连接，AP自身管理地址由上级路由DHCP分配，如需固定请修改LAN口地址。<br>并闭AP模式请选回“路由模式”。两种模式均为一次性动作，切换完成之后运行模式将自动显示为“当前模式。"))
o.default="none"
o:value("none",translate("当前模式"))
o:value("apmode",translate("AP模式"))
o:value("dhcpmode",translate("路由模式"))


if nixio.fs.access("/etc/dnsmasq.conf")then

s:tab("dnsmasqconf",translate("dnsmasq"),translate("本页是配置/etc/dnsmasq.conf的文档内容。应用保存后自动重启生效"))

conf=s:taboption("dnsmasqconf",Value,"dnsmasqconf",nil,translate("开头的数字符号（＃）或分号的每一行（;）被视为注释；删除（;）启用指定选项。"))
conf.template="cbi/tvalue"
conf.rows=20
conf.wrap="off"
conf.cfgvalue=function(t,t)
return e.readfile("/etc/dnsmasq.conf")or""
end
conf.write=function(a,a,t)
if t then
t=t:gsub("\r\n?","\n")
e.writefile("/tmp/dnsmasq.conf",t)
if(luci.sys.call("cmp -s /tmp/dnsmasq.conf /etc/dnsmasq.conf")==1)then
e.writefile("/etc/dnsmasq.conf",t)
luci.sys.call("/etc/init.d/dnsmasq restart >/dev/null")
end
e.remove("/tmp/dnsmasq.conf")
end
end
end
if nixio.fs.access("/etc/config/network")then
s:tab("netwrokconf",translate("网络"),translate("本页是配置/etc/config/network包含网络配置文档内容。应用保存后自动重启生效"))
conf=s:taboption("netwrokconf",Value,"netwrokconf",nil,translate("开头的数字符号（＃）或分号的每一行（;）被视为注释；删除（;）启用指定选项。"))
conf.template="cbi/tvalue"
conf.rows=20
conf.wrap="off"
conf.cfgvalue=function(t,t)
return e.readfile("/etc/config/network")or""
end
conf.write=function(a,a,t)
if t then
t=t:gsub("\r\n?","\n")
e.writefile("/tmp/network",t)
if(luci.sys.call("cmp -s /tmp/network /etc/config/network")==1)then
e.writefile("/etc/config/network",t)
luci.sys.call("/etc/init.d/network restart >/dev/null")
end
e.remove("/tmp/network")
end
end
end
if nixio.fs.access("/etc/hosts")then
s:tab("hostsconf",translate("hosts"),translate("本页是配置/etc/hosts的文档内容。应用保存后自动重启生效"))

conf=s:taboption("hostsconf",Value,"hostsconf",nil,translate("开头的数字符号（＃）或分号的每一行（;）被视为注释；删除（;）启用指定选项。"))
conf.template="cbi/tvalue"
conf.rows=20
conf.wrap="off"
conf.cfgvalue=function(t,t)
return e.readfile("/etc/hosts")or""
end
conf.write=function(a,a,t)
if t then
t=t:gsub("\r\n?","\n")
e.writefile("/tmp/hosts.tmp",t)
if(luci.sys.call("cmp -s /tmp/hosts.tmp /etc/hosts")==1)then
e.writefile("/etc/hosts",t)
luci.sys.call("/etc/init.d/dnsmasq restart >/dev/null")
end
e.remove("/tmp/hosts.tmp")
end
end
end
if nixio.fs.access("/etc/config/arpbind")then
s:tab("arpbindconf",translate("ARP绑定"),translate("本页是配置/etc/config/arpbind包含APR绑定MAC地址文档内容。应用保存后自动重启生效"))
conf=s:taboption("arpbindconf",Value,"arpbindconf",nil,translate("开头的数字符号（＃）或分号的每一行（;）被视为注释；删除（;）启用指定选项。"))
conf.template="cbi/tvalue"
conf.rows=20
conf.wrap="off"
conf.cfgvalue=function(t,t)
return e.readfile("/etc/config/arpbind")or""
end
conf.write=function(a,a,t)
if t then
t=t:gsub("\r\n?","\n")
e.writefile("/tmp/arpbind",t)
if(luci.sys.call("cmp -s /tmp/arpbind /etc/config/arpbind")==1)then
e.writefile("/etc/config/arpbind",t)
luci.sys.call("/etc/init.d/arpbind restart >/dev/null")
end
e.remove("/tmp/arpbind")
end
end
end
if nixio.fs.access("/etc/config/firewall")then
s:tab("firewallconf",translate("防火墙"),translate("本页是配置/etc/config/firewall包含防火墙协议设置文档内容。应用保存后自动重启生效"))
conf=s:taboption("firewallconf",Value,"firewallconf",nil,translate("开头的数字符号（＃）或分号的每一行（;）被视为注释；删除（;）启用指定选项。"))
conf.template="cbi/tvalue"
conf.rows=20
conf.wrap="off"
conf.cfgvalue=function(t,t)
return e.readfile("/etc/config/firewall")or""
end
conf.write=function(a,a,t)
if t then
t=t:gsub("\r\n?","\n")
e.writefile("/tmp/firewall",t)
if(luci.sys.call("cmp -s /tmp/firewall /etc/config/firewall")==1)then
e.writefile("/etc/config/firewall",t)
luci.sys.call("/etc/init.d/firewall restart >/dev/null")
end
e.remove("/tmp/firewall")
end
end
end
if nixio.fs.access("/etc/config/mwan3")then
s:tab("mwan3conf",translate("负载均衡"),translate("本页是配置/etc/config/mwan3包含负载均衡设置文档内容。应用保存后自动重启生效"))
conf=s:taboption("mwan3conf",Value,"mwan3conf",nil,translate("开头的数字符号（＃）或分号的每一行（;）被视为注释；删除（;）启用指定选项。"))
conf.template="cbi/tvalue"
conf.rows=20
conf.wrap="off"
conf.cfgvalue=function(t,t)
return e.readfile("/etc/config/mwan3")or""
end
conf.write=function(a,a,t)
if t then
t=t:gsub("\r\n?","\n")
e.writefile("/tmp/mwan3",t)
if(luci.sys.call("cmp -s /tmp/mwan3 /etc/config/mwan3")==1)then
e.writefile("/etc/config/mwan3",t)
luci.sys.call("/etc/init.d/mwan3 restart >/dev/null")
end
e.remove("/tmp/mwan3")
end
end
end
if nixio.fs.access("/etc/config/dhcp")then
s:tab("dhcpconf",translate("DHCP"),translate("本页是配置/etc/config/DHCP包含机器名等设置文档内容。应用保存后自动重启生效"))
conf=s:taboption("dhcpconf",Value,"dhcpconf",nil,translate("开头的数字符号（＃）或分号的每一行（;）被视为注释；删除（;）启用指定选项。"))
conf.template="cbi/tvalue"
conf.rows=20
conf.wrap="off"
conf.cfgvalue=function(t,t)
return e.readfile("/etc/config/dhcp")or""
end
conf.write=function(a,a,t)
if t then
t=t:gsub("\r\n?","\n")
e.writefile("/tmp/dhcp",t)
if(luci.sys.call("cmp -s /tmp/dhcp /etc/config/dhcp")==1)then
e.writefile("/etc/config/dhcp",t)
luci.sys.call("/etc/init.d/network restart >/dev/null")
end
e.remove("/tmp/dhcp")
end
end
end
if nixio.fs.access("/etc/config/ddns")then
s:tab("ddnsconf",translate("DDNS"),translate("本页是配置/etc/config/ddns包含动态域名设置文档内容。应用保存后自动重启生效"))
conf=s:taboption("ddnsconf",Value,"ddnsconf",nil,translate("开头的数字符号（＃）或分号的每一行（;）被视为注释；删除（;）启用指定选项。"))
conf.template="cbi/tvalue"
conf.rows=20
conf.wrap="off"
conf.cfgvalue=function(t,t)
return e.readfile("/etc/config/ddns")or""
end
conf.write=function(a,a,t)
if t then
t=t:gsub("\r\n?","\n")
e.writefile("/tmp/ddns",t)
if(luci.sys.call("cmp -s /tmp/ddns /etc/config/ddns")==1)then
e.writefile("/etc/config/ddns",t)
luci.sys.call("/etc/init.d/ddns restart >/dev/null")
end
e.remove("/tmp/ddns")
end
end
end

if nixio.fs.access("/etc/config/timecontrol")then
s:tab("timecontrolconf",translate("时间控制"),translate("本页是配置/etc/config/timecontrol包含上网时间控制配置文档内容。应用保存后自动重启生效"))
conf=s:taboption("timecontrolconf",Value,"timecontrolconf",nil,translate("开头的数字符号（＃）或分号的每一行（;）被视为注释；删除（;）启用指定选项。"))
conf.template="cbi/tvalue"
conf.rows=20
conf.wrap="off"
conf.cfgvalue=function(t,t)
return e.readfile("/etc/config/timecontrol")or""
end
conf.write=function(a,a,t)
if t then
t=t:gsub("\r\n?","\n")
e.writefile("/tmp/timecontrol",t)
if(luci.sys.call("cmp -s /tmp/timecontrol /etc/config/timecontrol")==1)then
e.writefile("/etc/config/timecontrol",t)
luci.sys.call("/etc/init.d/timecontrol restart >/dev/null")
end
e.remove("/tmp/timecontrol")
end
end
end
if nixio.fs.access("/etc/config/rebootschedule")then
s:tab("rebootscheduleconf",translate("定时设置"),translate("本页是配置/etc/config/rebootschedule包含定时设置任务配置文档内容。应用保存后自动重启生效"))
conf=s:taboption("rebootscheduleconf",Value,"rebootscheduleconf",nil,translate("开头的数字符号（＃）或分号的每一行（;）被视为注释；删除（;）启用指定选项。"))
conf.template="cbi/tvalue"
conf.rows=20
conf.wrap="off"
conf.cfgvalue=function(t,t)
return e.readfile("/etc/config/rebootschedule")or""
end
conf.write=function(a,a,t)
if t then
t=t:gsub("\r\n?","\n")
e.writefile("/tmp/rebootschedule",t)
if(luci.sys.call("cmp -s /tmp/rebootschedule /etc/config/rebootschedule")==1)then
e.writefile("/etc/config/rebootschedule",t)
luci.sys.call("/etc/init.d/rebootschedule restart >/dev/null")
end
e.remove("/tmp/rebootschedule")
end
end
end
if nixio.fs.access("/etc/config/wolplus")then
s:tab("wolplusconf",translate("网络唤醒"),translate("本页是配置/etc/config/wolplus包含网络唤醒配置文档内容。应用保存后自动重启生效"))
conf=s:taboption("wolplusconf",Value,"wolplusconf",nil,translate("开头的数字符号（＃）或分号的每一行（;）被视为注释；删除（;）启用指定选项。"))
conf.template="cbi/tvalue"
conf.rows=20
conf.wrap="off"
conf.cfgvalue=function(t,t)
return e.readfile("/etc/config/wolplus")or""
end
conf.write=function(a,a,t)
if t then
t=t:gsub("\r\n?","\n")
e.writefile("/tmp/wolplus",t)
if(luci.sys.call("cmp -s /tmp/wolplus /etc/config/wolplus")==1)then
e.writefile("/etc/config/wolplus",t)
luci.sys.call("/etc/init.d/wolplus restart >/dev/null")
end
e.remove("/tmp/wolplus")
end
end
end

if nixio.fs.access("/etc/config/smartdns")then
s:tab("smartdnsconf",translate("SMARTDNS"),translate("本页是配置/etc/config/smartdns包含smartdns配置文档内容。应用保存后自动重启生效"))
conf=s:taboption("smartdnsconf",Value,"smartdnsconf",nil,translate("开头的数字符号（＃）或分号的每一行（;）被视为注释；删除（;）启用指定选项。"))
conf.template="cbi/tvalue"
conf.rows=20
conf.wrap="off"
conf.cfgvalue=function(t,t)
return e.readfile("/etc/config/smartdns")or""
end
conf.write=function(a,a,t)
if t then
t=t:gsub("\r\n?","\n")
e.writefile("/tmp/smartdns",t)
if(luci.sys.call("cmp -s /tmp/smartdns /etc/config/smartdns")==1)then
e.writefile("/etc/config/smartdns",t)
luci.sys.call("/etc/init.d/smartdns restart >/dev/null")
end
e.remove("/tmp/smartdns")
end
end
end
if nixio.fs.access("/etc/config/openclash")then
s:tab("openclashconf",translate("openclash"),translate("本页是配置/etc/config/openclash的文档内容。应用保存后自动重启生效"))
conf=s:taboption("openclashconf",Value,"openclashconf",nil,translate("开头的数字符号（＃）或分号的每一行（;）被视为注释；删除（;）启用指定选项。"))
conf.template="cbi/tvalue"
conf.rows=20
conf.wrap="off"
conf.cfgvalue=function(t,t)
return e.readfile("/etc/config/openclash")or""
end
conf.write=function(a,a,t)
if t then
t=t:gsub("\r\n?","\n")
e.writefile("/tmp/openclash",t)
if(luci.sys.call("cmp -s /tmp/openclash /etc/config/openclash")==1)then
e.writefile("/etc/config/openclash",t)
luci.sys.call("/etc/init.d/openclash restart >/dev/null")
end
e.remove("/tmp/openclash")
end
end
end

if nixio.fs.access("/bin/nuc")then
	s:tab("mode",translate("模式切换(旁路由）"),translate("<br />可以在这里切换旁路由和正常模式，重置你的网络设置。<br /><font color=\"Red\"><strong>点击后会立即重启设备，没有确认过程，请谨慎操作！</strong></font><br/>"))
	o=s:taboption("mode",Button,"nucmode",translate("切换为旁路由模式"),translate("<font color=\"green\"><strong>本模式适合于单网口主机，如NUC、单网口电脑！<br />默认gateway是：192.168.1.1，ipaddr是192.168.1.2。用本机接口LAN接上级LAN当旁路由，主路由关闭DHCP服务。</strong></font><br/>"))
	o.inputtitle=translate("NUC模式")
	o.inputstyle="reload"

	o.write=function()
	luci.sys.call("/bin/nuc")
	end



	o=s:taboption("mode",Button,"normalmode",translate("切换成正常模式"),translate("<font color=\"green\"><strong>本模式适合于有两个网口或以上的设备使用，如多网口软路由或者虚拟了两个以上网口的虚拟机使用！</strong></font><br/>"))
	o.inputtitle=translate("正常模式")
	o.inputstyle="reload"

	o.write=function()
	luci.sys.call("/bin/normalmode")
	end
end

return m
