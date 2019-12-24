#! /usr/bin/awk -f
#
# Copyright (C) 2006  Free Software Foundation, Inc.
#
# This genmoddep.awk is free software; the author
# gives unlimited permission to copy and/or distribute it,
# with or without modifications, as long as this notice is preserved.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY, to the extent permitted by law; without
# even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE.

# Read symbols' info from stdin.
BEGIN {
    error = 0
}

# 创建一个symbol table, 容纳所有的symbol(不重复) *此处有坑* 重复symbol会覆盖
# 创建一个module table, 容纳所有的module
# 文件内容格式:
# defined kernel grub_print_error
# defined kernel grub_printf
# defined kernel grub_strlen
# defined kernel grub_xasprintf
# defined kernel grub_xputs
# defined zfs fletcher_2
# defined zfs grub_zfs_decrypt
# defined zfs grub_zfs_fetch_nvlist
# defined zfs grub_zfs_getmdnobj
# defined zfs grub_zfs_load_key
# defined zfs grub_zfs_nvlist_lookup_nvlist
# defined zfs grub_zfs_nvlist_lookup_nvlist_array
# defined zfs grub_zfs_nvlist_lookup_string
# defined zfs grub_zfs_nvlist_lookup_uint64
# defined zfs lz4_decompress
# defined zfs lzjb_decompress
# defined zfs zio_checksum_SHA256
# undefined zfsinfo grub_printf
# undefined zfsinfo grub_strlen
# undefined zfsinfo grub_xasprintf
# undefined zfsinfo grub_xputs
# undefined zfsinfo grub_zfs_fetch_nvlist
# undefined zfsinfo grub_zfs_getmdnobj
# undefined zfsinfo grub_zfs_nvlist_lookup_nvlist
# undefined zfsinfo grub_zfs_nvlist_lookup_nvlist_array
# undefined zfsinfo grub_zfs_nvlist_lookup_string
# undefined zfsinfo grub_zfs_nvlist_lookup_uint64

{
    if ($1 == "defined") {
	symtab[$3] = $2;
	# symtab["grub_print_error"] = "kernel" 此处如果后面有不同模块定义了同一symbol则会覆盖
	# symtab["grub_printf"] = "kernel"
	# symtab["grub_strlen"] = "kernel"
	# symtab["grub_xasprintf"] = "kernel"
	# symtab["grub_xputs"] = "kernel"
	# symtab["fletcher_2"] = "zfs"
	# symtab["grub_zfs_decrypt"] = "zfs"
	# symtab["grub_zfs_fetch_nvlist"] = "zfs"
	# symtab["grub_zfs_getmdnobj"] = "zfs"
	# symtab["grub_zfs_load_key"] = "zfs"
	# symtab["grub_zfs_nvlist_lookup_nvlist"] = "zfs"
	# symtab["grub_zfs_nvlist_lookup_nvlist_array"] = "zfs"
	# symtab["grub_zfs_nvlist_lookup_string"] = "zfs"
	# symtab["grub_zfs_nvlist_lookup_uint64"] = "zfs"
	# symtab["lz4_decompress"] = "zfs"
	# symtab["lzjb_decompress"] = "zfs"
	# symtab["zio_checksum_SHA256"] = "zfs"
	modtab[$2] = "" modtab[$2]
	# modtab["kernel"] = " kernel"
	# modtab["zfs"] = "zfs"
    } else if ($1 == "undefined") {
	# undefined zfsinfo grub_printf
	if ($3 in symtab)
	    # modtab["zfsinfo"] = modtab["zfsinfo"] " " symtab["grub_printf"]
	    # modtab["zfsinfo"] = " kernel"
	    # modtab["zfsinfo"] = " kernel kernel kernel kernel zfs zfs zfs zfs zfs zfs"
	    modtab[$2] = modtab[$2] " " symtab[$3];
	else if ($3 != "__gnu_local_gp" && $3 != "_gp_disp") {
	    printf "%s in %s is not defined\n", $3, $2 >"/dev/stderr";
	    error++;
	}
    }
    else {
	printf "error: %u: unrecognized input format\n", NR >"/dev/stderr";
	error++;
    }
}

# Output the result.
END {
    if (error >= 1)
	exit 1;

    total_depcount = 0
  
    for (mod in modtab) {
	# modtab["kernel"] = "kernel"
	# modtab["zfs"] = "zfs"
	# modtab["zfsinfo"] = " kernel kernel kernel kernel zfs zfs zfs zfs zfs zfs"

	# Remove duplications.
	split(modtab[mod], depmods, " ");
	# depmods ["kernel"]
	# depmods ["zfs"]
	# depmods ["kernel" "kernel" "kernel" "kernel" "zfs" "zfs" "zfs" "zfs" "zfs" "zfs"]
	for (depmod in uniqmods) {
	    # 清空 uniqmods 数组
	    delete uniqmods[depmod];
	}
	for (i in depmods) {
	    depmod = depmods[i];
	    # Ignore kernel, as always loaded.
	    if (depmod != "kernel" && depmod != mod)
		# 对于 modtab["zfsinfo"]:
		# uniqmods["zfs"] = 1
		uniqmods[depmod] = 1;
	}
	modlist = ""
	depcount[mod] = 0
	# depcount["zfsinfo"] = 0
	for (depmod in uniqmods) {
	    # modlist = "" + " " + "zfs"
	    modlist = modlist " " depmod;
	    # inverse_dependencies["zfs"] = "" + " " + "zfsinfo"
	    inverse_dependencies[depmod] = inverse_dependencies[depmod] " " mod
	    depcount[mod]++
	    # depcount["zfsinfo"] ++
	    total_depcount++
	    # total_depcount++
	}
	if (mod == "all_video") {
	    continue;
	}
	printf "%s:%s\n", mod, modlist;
    }

    # Check that we have no dependency circles
    while (total_depcount != 0) {
	something_done = 0
	for (mod in depcount) {
	    printf "processing module: %s\n", mod >"/dev/stderr";
	    if (depcount[mod] == 0) {
		delete depcount[mod]
		split(inverse_dependencies[mod], inv_depmods, " ");
		for (ctr in inv_depmods) {
		    depcount[inv_depmods[ctr]]--
		    total_depcount--
		}
		delete inverse_dependencies[mod]
		something_done = 1
	    } else {
		printf "depcount[%s] == %s", mod, depcount[mod] >"/dev/stderr";
	    }
	}
	if (something_done == 0) {
	    for (mod in depcount) {
		circle = circle " " mod
	    }
	    printf "error: modules %s form a dependency circle\n", circle >"/dev/stderr";
	    exit 1
	}
    }
    modlist = ""
    while (getline <"video.lst") {
	modlist = modlist " " $1;
    }
    printf "all_video:%s\n", modlist;
}
