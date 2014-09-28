module.exports = [{
		"managed": {
			"package.json": {
				"manager": "npm"
			}
		}
	}, {
		"managed": {
			"package.json": {
				"manager": "npm"
			},
			"requirements.txt": {
				"manager": "pypi"
			},
			"dpkg.txt": {
				"manager": "dpkg"
			}
		}
	}, {
		"unmanaged": [{
			"name": "some package name",
			"version": "4.2.0",
			"homepage": "github.com/something/some-package-name"
		}]
	}


]