../../scripts/03_process_epacts.sh | tee 03_process_epacts.log
../../scripts/04_process_info.sh | tee 04_process_info.log
../../scripts/05_join_gwas_info.sh | tee 05_join_gwas_info.log
../../scripts/06_gwasqc.sh | tee 06_gwasqc.log
../../scripts/07_plot_positions.sh | tee 07_plot_positions.log
../../scripts/08_plot_freqs_kgp_detect_POP.sh | tee 08_plot_freqs_kgp_detect_POP.log
../../scripts/09_check_controls.sh | tee 09_check_controls.log
#../../scripts/10_cleanup.sh | tee 10_cleanup.log
../../scripts/11_extract_summaries.sh | tee 11_summary.log

