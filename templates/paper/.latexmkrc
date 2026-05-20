$do_cd = 1;

$out_dir = '.cache/out';
$aux_dir = '.cache/aux';
$out2_dir = $out_dir;
$emulate_aux = 1;

$biber =
    'biber '
    . '--input-directory=.cache/aux '
    . '--output-directory=.cache/aux '
    . '%B';
