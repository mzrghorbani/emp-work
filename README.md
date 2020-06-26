In the emp-work repository, the generated IP-Core from lr_make_hls_ip directory is utilized into EMP framework and simulation files are created and executed by modelsim.

The repository contains three scripts which make the process smoother:

1- make_proj:

	1.1- Creates a new work area.
	1.2- Downloads dependencies from GitLab.
	1.3- Creates new directories and top-level dependency files.
	1.4- Creates a Vivado project using EMP-FWK settings.
	1.5- Runs Vivado synthesis, implements the FPGA board
	1.6- Export the created IP-Core as Vivado packages

2- make_sim:

	2.1- Creates dependencies for simulations.
	2.2- Utilizes IP-Cores and simulation libraries.
	2.3- Creates a modelsim project.

3- run_sim

	3.1- Compiles newly added VHDL modules.
	3.2- Run modelsim simulation using txt-files.
	3.3- Generates txt-files for analysis.

There are two directories:

1- txt_files:

	The input test-vectors are kept in producer file format.

2- emp-payload:

	The emp_payload.vhd top-level for different versions of the LRHLS module.

For more imformation contact: Maziar.Ghorbani@brunel.ac.uk