%% 加载必要的目录

cur_path = pwd();
paths = [
    cur_path,'/tftb-0.2/mfiles;', ...% tftb toolbox
    cur_path,'/tftb-0.2/tests;', ...
    cur_path,'/tftb-0.2/data;', ...
    cur_path,'/tftb-0.2/demos;', ...
    cur_path,'/tfsa_7.0/win64_bin;', ... % tfsa toolbox
    cur_path,'/synchrosqueezing/synchrosqueezing;', ... % synchrosqueezing toolbox
    cur_path,'/synchrosqueezing/util;',
    ];
addpath( paths );

pathtool; %点击保存
clear all;
