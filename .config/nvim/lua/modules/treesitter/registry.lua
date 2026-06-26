local M = {}

M.ensure_installed = {
	"arduino",
	"awk",
	"bash",
	"bibtex",
	"c",
	"cmake",
	"comment",
	"cpp",
	"css",
	"csv",
	"diff",
	"dockerfile",
	"doxygen",
	"fortran",
	"git_config",
	"git_rebase",
	"gitattributes",
	"gitcommit",
	"gitignore",
	"gnuplot",
	"go",
	"gomod",
	"gosum",
	"gpg",
	"graphql",
	"groovy",
	"html",
	"java",
	"javascript",
	"jq",
	"jsdoc",
	"json",
	"jsonc",
	"latex",
	"ledger",
	"lua",
	"luadoc",
	"luap",
	"make",
	"markdown",
	"markdown_inline",
	"mermaid",
	"muttrc",
	"ninja",
	"nix",
	"norg",
	"ocaml",
	"org",
	"passwd",
	"pem",
	"php",
	"printf",
	"python",
	"query",
	"r",
	"regex",
	"requirements",
	"ruby",
	"rust",
	"sql",
	"ssh_config",
	"strace",
	"tmux",
	"todotxt",
	"toml",
	"tsv",
	"tsx",
	"typescript",
	"vim",
	"vimdoc",
	"xml",
	"yaml",
}

M.aliases = {
	bash = { "sh", "zsh" },
	cpp = { "cxx" },
	git_config = { "gitconfig" },
	git_rebase = { "gitrebase" },
	javascript = { "javascriptreact" },
	json = { "jsonc" },
	latex = { "tex", "plaintex", "rnoweb" },
	ssh_config = { "sshconfig" },
	tsx = { "typescriptreact" },
	xml = { "svg", "xslt" },
	yaml = { "yml" },
}

M.parsers = {
	arduino = {
		repo = "https://github.com/tree-sitter-grammars/tree-sitter-arduino",
		revision = "11dd46c9ae25135c473c0003a133bb06a484af0c",
	},
	awk = {
		repo = "https://github.com/Beaglefoot/tree-sitter-awk",
		revision = "34bbdc7cce8e803096f47b625979e34c1be38127",
	},
	bash = {
		repo = "https://github.com/tree-sitter/tree-sitter-bash",
		revision = "a06c2e4415e9bc0346c6b86d401879ffb44058f7",
	},
	bibtex = {
		repo = "https://github.com/latex-lsp/tree-sitter-bibtex",
		revision = "8d04ed27b3bc7929f14b7df9236797dab9f3fa66",
	},
	c = {
		repo = "https://github.com/tree-sitter/tree-sitter-c",
		revision = "ae19b676b13bdcc13b7665397e6d9b14975473dd",
	},
	cmake = {
		repo = "https://github.com/uyha/tree-sitter-cmake",
		revision = "c7b2a71e7f8ecb167fad4c97227c838439280175",
	},
	comment = {
		repo = "https://github.com/stsewd/tree-sitter-comment",
		revision = "66272d2b6c73fb61157541b69dd0a7ce7b42a5ad",
	},
	cpp = {
		repo = "https://github.com/tree-sitter/tree-sitter-cpp",
		revision = "8b5b49eb196bec7040441bee33b2c9a4838d6967",
	},
	css = {
		repo = "https://github.com/tree-sitter/tree-sitter-css",
		revision = "dda5cfc5722c429eaba1c910ca32c2c0c5bb1a3f",
	},
	csv = {
		repo = "https://github.com/tree-sitter-grammars/tree-sitter-csv",
		revision = "f6bf6e35eb0b95fbadea4bb39cb9709507fcb181",
		location = "csv",
	},
	diff = {
		repo = "https://github.com/tree-sitter-grammars/tree-sitter-diff",
		revision = "2520c3f934b3179bb540d23e0ef45f75304b5fed",
	},
	dockerfile = {
		repo = "https://github.com/camdencheek/tree-sitter-dockerfile",
		revision = "971acdd908568b4531b0ba28a445bf0bb720aba5",
	},
	doxygen = {
		repo = "https://github.com/tree-sitter-grammars/tree-sitter-doxygen",
		revision = "ccd998f378c3f9345ea4eeb223f56d7b84d16687",
	},
	fortran = {
		repo = "https://github.com/stadelmanma/tree-sitter-fortran",
		revision = "be30d90dc7dfa4080b9c4abed3f400c9163a88df",
	},
	git_config = {
		repo = "https://github.com/the-mikedavis/tree-sitter-git-config",
		revision = "0fbc9f99d5a28865f9de8427fb0672d66f9d83a5",
	},
	git_rebase = {
		repo = "https://github.com/the-mikedavis/tree-sitter-git-rebase",
		revision = "760ba8e34e7a68294ffb9c495e1388e030366188",
	},
	gitattributes = {
		repo = "https://github.com/tree-sitter-grammars/tree-sitter-gitattributes",
		revision = "1b7af09d45b579f9f288453b95ad555f1f431645",
	},
	gitcommit = {
		repo = "https://github.com/gbprod/tree-sitter-gitcommit",
		revision = "33fe8548abcc6e374feaac5724b5a2364bf23090",
	},
	gitignore = {
		repo = "https://github.com/shunsambongi/tree-sitter-gitignore",
		revision = "f4685bf11ac466dd278449bcfe5fd014e94aa504",
	},
	gnuplot = {
		repo = "https://github.com/dpezto/tree-sitter-gnuplot",
		revision = "8923c1e38b9634a688a6c0dce7c18c8ffb823e79",
	},
	go = {
		repo = "https://github.com/tree-sitter/tree-sitter-go",
		revision = "2346a3ab1bb3857b48b29d779a1ef9799a248cd7",
	},
	gomod = {
		repo = "https://github.com/camdencheek/tree-sitter-go-mod",
		revision = "2e886870578eeba1927a2dc4bd2e2b3f598c5f9a",
	},
	gosum = {
		repo = "https://github.com/tree-sitter-grammars/tree-sitter-go-sum",
		revision = "27816eb6b7315746ae9fcf711e4e1396dc1cf237",
	},
	gpg = {
		repo = "https://github.com/tree-sitter-grammars/tree-sitter-gpg-config",
		revision = "4024eb268c59204280f8ac71ef146b8ff5e737f6",
	},
	graphql = {
		repo = "https://github.com/bkegley/tree-sitter-graphql",
		revision = "5e66e961eee421786bdda8495ed1db045e06b5fe",
	},
	groovy = {
		repo = "https://github.com/murtaza64/tree-sitter-groovy",
		revision = "781d9cd1b482a70a6b27091e5c9e14bbcab3b768",
	},
	html = {
		repo = "https://github.com/tree-sitter/tree-sitter-html",
		revision = "73a3947324f6efddf9e17c0ea58d454843590cc0",
	},
	java = {
		repo = "https://github.com/tree-sitter/tree-sitter-java",
		revision = "e10607b45ff745f5f876bfa3e94fbcc6b44bdc11",
	},
	javascript = {
		repo = "https://github.com/tree-sitter/tree-sitter-javascript",
		revision = "58404d8cf191d69f2674a8fd507bd5776f46cb11",
	},
	jq = {
		repo = "https://github.com/flurie/tree-sitter-jq",
		revision = "c204e36d2c3c6fce1f57950b12cabcc24e5cc4d9",
	},
	jsdoc = {
		repo = "https://github.com/tree-sitter/tree-sitter-jsdoc",
		revision = "658d18dcdddb75c760363faa4963427a7c6b52db",
	},
	json = {
		repo = "https://github.com/tree-sitter/tree-sitter-json",
		revision = "001c28d7a29832b06b0e831ec77845553c89b56d",
	},
	latex = {
		repo = "https://github.com/latex-lsp/tree-sitter-latex",
		revision = "7e0ecdc02926c7b9b2e0c76003d4fe7b0944f957",
		generate = true,
	},
	ledger = {
		repo = "https://github.com/cbarrete/tree-sitter-ledger",
		revision = "22a1ab8195c1f6e808679f803007756fe7638c6f",
	},
	lua = {
		repo = "https://github.com/tree-sitter-grammars/tree-sitter-lua",
		revision = "10fe0054734eec83049514ea2e718b2a56acd0c9",
	},
	luadoc = {
		repo = "https://github.com/tree-sitter-grammars/tree-sitter-luadoc",
		revision = "873612aadd3f684dd4e631bdf42ea8990c57634e",
	},
	luap = {
		repo = "https://github.com/tree-sitter-grammars/tree-sitter-luap",
		revision = "c134aaec6acf4fa95fe4aa0dc9aba3eacdbbe55a",
	},
	make = {
		repo = "https://github.com/tree-sitter-grammars/tree-sitter-make",
		revision = "70613f3d812cbabbd7f38d104d60a409c4008b43",
	},
	markdown = {
		repo = "https://github.com/tree-sitter-grammars/tree-sitter-markdown",
		revision = "f969cd3ae3f9fbd4e43205431d0ae286014c05b5",
		location = "tree-sitter-markdown",
	},
	markdown_inline = {
		repo = "https://github.com/tree-sitter-grammars/tree-sitter-markdown",
		revision = "f969cd3ae3f9fbd4e43205431d0ae286014c05b5",
		location = "tree-sitter-markdown-inline",
	},
	mermaid = {
		repo = "https://github.com/monaqa/tree-sitter-mermaid",
		revision = "90ae195b31933ceb9d079abfa8a3ad0a36fee4cc",
	},
	muttrc = {
		repo = "https://github.com/neomutt/tree-sitter-muttrc",
		revision = "173b0ab53a9c07962c9777189c4c70e90f1c1837",
	},
	ninja = {
		repo = "https://github.com/alemuller/tree-sitter-ninja",
		revision = "0a95cfdc0745b6ae82f60d3a339b37f19b7b9267",
	},
	nix = {
		repo = "https://github.com/nix-community/tree-sitter-nix",
		revision = "eabf96807ea4ab6d6c7f09b671a88cd483542840",
	},
	ocaml = {
		repo = "https://github.com/tree-sitter/tree-sitter-ocaml",
		revision = "5a979b3ec7f1fe990b8e8c4412294a0cf7228e45",
		location = "grammars/ocaml",
	},
	passwd = {
		repo = "https://github.com/ath3/tree-sitter-passwd",
		revision = "20239395eacdc2e0923a7e5683ad3605aee7b716",
	},
	pem = {
		repo = "https://github.com/tree-sitter-grammars/tree-sitter-pem",
		revision = "e525b177a229b1154fd81bc0691f943028d9e685",
	},
	php = {
		repo = "https://github.com/tree-sitter/tree-sitter-php",
		revision = "3f2465c217d0a966d41e584b42d75522f2a3149e",
		location = "php",
	},
	printf = {
		repo = "https://github.com/tree-sitter-grammars/tree-sitter-printf",
		revision = "ec4e5674573d5554fccb87a887c97d4aec489da7",
	},
	python = {
		repo = "https://github.com/tree-sitter/tree-sitter-python",
		revision = "v0.25.0",
	},
	query = {
		repo = "https://github.com/tree-sitter-grammars/tree-sitter-query",
		revision = "fc5409c6820dd5e02b0b0a309d3da2bfcde2db17",
	},
	r = {
		repo = "https://github.com/r-lib/tree-sitter-r",
		revision = "0e6ef7741712c09dc3ee6e81c42e919820cc65ef",
	},
	regex = {
		repo = "https://github.com/tree-sitter/tree-sitter-regex",
		revision = "b2ac15e27fce703d2f37a79ccd94a5c0cbe9720b",
	},
	requirements = {
		repo = "https://github.com/tree-sitter-grammars/tree-sitter-requirements",
		revision = "caeb2ba854dea55931f76034978de1fd79362939",
	},
	ruby = {
		repo = "https://github.com/tree-sitter/tree-sitter-ruby",
		revision = "ad907a69da0c8a4f7a943a7fe012712208da6dee",
	},
	rust = {
		repo = "https://github.com/tree-sitter/tree-sitter-rust",
		revision = "77a3747266f4d621d0757825e6b11edcbf991ca5",
	},
	sql = {
		repo = "https://github.com/derekstride/tree-sitter-sql",
		revision = "851e9cb257ba7c66cc8c14214a31c44d2f1e954e",
	},
	ssh_config = {
		repo = "https://github.com/tree-sitter-grammars/tree-sitter-ssh-config",
		revision = "71d2693deadaca8cdc09e38ba41d2f6042da1616",
	},
	strace = {
		repo = "https://github.com/sigmaSd/tree-sitter-strace",
		revision = "ac874ddfcc08d689fee1f4533789e06d88388f29",
	},
	tmux = {
		repo = "https://github.com/Freed-Wu/tree-sitter-tmux",
		revision = "75d1b995b0c23400ac8e49db757a2e0386f9fa8f",
	},
	todotxt = {
		repo = "https://github.com/arnarg/tree-sitter-todotxt",
		revision = "3937c5cd105ec4127448651a21aef45f52d19609",
	},
	toml = {
		repo = "https://github.com/tree-sitter-grammars/tree-sitter-toml",
		revision = "64b56832c2cffe41758f28e05c756a3a98d16f41",
	},
	tsv = {
		repo = "https://github.com/tree-sitter-grammars/tree-sitter-csv",
		revision = "f6bf6e35eb0b95fbadea4bb39cb9709507fcb181",
		location = "tsv",
	},
	tsx = {
		repo = "https://github.com/tree-sitter/tree-sitter-typescript",
		revision = "75b3874edb2dc714fb1fd77a32013d0f8699989f",
		location = "tsx",
	},
	typescript = {
		repo = "https://github.com/tree-sitter/tree-sitter-typescript",
		revision = "75b3874edb2dc714fb1fd77a32013d0f8699989f",
		location = "typescript",
	},
	vim = {
		repo = "https://github.com/tree-sitter-grammars/tree-sitter-vim",
		revision = "3092fcd99eb87bbd0fc434aa03650ba58bd5b43b",
	},
	vimdoc = {
		repo = "https://github.com/neovim/tree-sitter-vimdoc",
		revision = "f061895a0eff1d5b90e4fb60d21d87be3267031a",
	},
	xml = {
		repo = "https://github.com/tree-sitter-grammars/tree-sitter-xml",
		revision = "5000ae8f22d11fbe93939b05c1e37cf21117162d",
		location = "xml",
	},
	yaml = {
		repo = "https://github.com/tree-sitter-grammars/tree-sitter-yaml",
		revision = "4463985dfccc640f3d6991e3396a2047610cf5f8",
	},
}

return M
