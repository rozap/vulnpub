

vulns 		package
	|		|
	|		|
	|		|
	vuln_effect
		- vulnerable t/f
		- version
		- 


on new vuln:
	- find all packages having name like vuln_effects (where vulnerable = true) 
		and where package_version matches any of vuln_effects


