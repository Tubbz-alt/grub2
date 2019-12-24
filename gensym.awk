#! /usr/bin/awk -f
BEGIN {
    error = 0
}
{
    if ($1 == "defined") {
	symtab[$3] = $2;
	modtab[$2] = "" modtab[$2]
    } else if ($1 == "undefined") {
	if ($3 in symtab)
	    modtab[$2] = modtab[$2] " " symtab[$3];
	else if ($3 != "__gnu_local_gp" && $3 != "_gp_disp") {
	    printf "%s in %s is not defined\n", $3, $2 >"/dev/stderr";
	    error++;
	}
    }
    else {
	printf "%s, %s, %s\n", $1, $2, $3 >"/dev/stderr";
	printf "error: %u: unrecognized input format\n", NR >"/dev/stderr";
	error++;
    }
}
END {
    total_depcount = 0
    
    for (mod in modtab) {
	split(modtab[mod], depmods, " ");

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

#	printf "Uniqmods for %s is: ", mod;
#	for (i in uniqmods) {
#	    printf " %s ", i;
#	}
#	printf "\n";

	modlist = ""
	depcount[mod] = 0
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
	modlist_t[mod]=modlist
#	printf "Mod %s depcount: %s\n", mod, depcount[mod];
	printf "Uniq %s: %s\n", mod, modlist;
    }

    printf "Total depcount: %s\n", total_depcount;

    for (m in inverse_dependencies){
	printf "Inverse %s: %s\n", m, inverse_dependencies[m];
    }
    while (total_depcount != 0) {
	printf "Round %s\n", total_depcount;
	something_done = 0
	for (mod in depcount) {
	    printf "depcount[%s] == %s\n", mod, depcount[mod];
	    if (depcount[mod] == 0) {
		printf "processing module: %s\n", mod;
		delete depcount[mod]
		split(inverse_dependencies[mod], inv_depmods, " ");
		for (ctr in inv_depmods) {
		    depcount[inv_depmods[ctr]]--
		    total_depcount--
		}
		delete inverse_dependencies[mod]
		printf "something_done is now becomes 1\n" >"/dev/stderr";
		something_done = 1
	    } else {
		
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
}
