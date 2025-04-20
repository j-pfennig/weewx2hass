#!/usr/bin/bash
if [ -z "$CEN_HOOK_MESSAGE" ];then
{
{
CEN_STDOUT=41
CEN_STDERR=42
eval exec "$CEN_STDOUT>&1" "$CEN_STDERR>&2"
CEN_EXIT=0
CEN_HOOK_MESSAGE='message'
CEN_HOOK_QUIT=
CEN_IDNT=
CEN_MINI_VERSION='0.05'
: ${CEN_VERSION:=$CEN_MINI_VERSION}
CEN_ARGS=
CEN_ARGOPT=
CEN_ACTARR=
CEN_CONFIRM=
CEN_OPT_DRYRUN=
CEN_OPT_FORCE=
CEN_TMP_BASE="${TMPDIR:-/tmp}/$EPOCHSECONDS-$BASHPID-"
CEN_TMP_INDX=0
CEN_TMP_SYSO=
CEN_TMPFILE=
CEN_VERB=1
CEN_YESNO=
}
warning(){ message -w "$@";}
error(){ message -e -l "$@";return "$CEN_EXIT";}
fatal(){ [ "$1" = '-t' ]&&set -- "${@:2}";message -f -l "$@";quit;}
trace(){ [ "$CEN_VERB" -lt 2 ]&&return 0;message "$@";}
message(){
local _idnt="$CEN_NAME:" _exit _mesg _olog="$CEN_VERB" _opre _oqui _omul _opri
while [ "${1::1}" = - ];do
case "$1" in
-)break;;
--)shift;break;;
-a)[ -n "$CEN_IDNT" ]&&_idnt="${_idnt//?/ }";;
-c)
local _asci _ugly
_asci="${2//[[:alpha:]]/.}"
printf -v _ugly $"%-16s:" "$_asci"
printf -v _opre '%s' "${_ugly/$_asci/$2}"
shift;;
-e)_opre=$"***ERROR***";_exit=2;;
-f)_opre=$"***FATAL ERROR***";_exit=3;;
-i)_idnt="${_idnt//?/ }";;
-l)_olog=1;;
-m)_omul=1;;
-p)_opri=1;;
-q)[ "$CEN_EXIT" = 0 ]&&return 0;_oqui=1;;
-t)[ "$CEN_EXIT" = 0 ];return;;
-w)_opre=$"***WARNING***";;
esac;shift
done
[ -n "$_exit" ]&&{ _olog=1;CEN_EXIT="$_exit";}
[ -n "$_oqui" ]&&quit -e "$@"
[ "$_olog" -lt 1 ]&&return 0
if [ -n "$_omul" ];then
_omul="$1";shift
set -- "$_omul${@/*/$'\n'${_idnt//?/ } &}"
fi
[ -z "$_opri" ]&&_mesg="$*"||printf -v _mesg "$@"
[ -n "$_opre" ]&&_mesg="$_opre $_mesg"
echo "$_idnt" "$_mesg" >&2
CEN_IDNT=1
}
confirm(){
local _ofmt _oupc _what=1 _repl _vnam='CEN_CONFIRM' _idnt="$CEN_NAME:" _info _defn _text
while [ "${1::1}" = - ];do
case "$1" in
--)shift;break;;
-a)[ -n "$CEN_IDNT" ]&&_idnt="${_idnt//?/ }";;
-d)shift;_defn="$1";;
-f)_ofmt=1;;
-i)_idnt="${_idnt//?/ }";;
-n)_what=1;;
-p)shift;_what=;_info="$1";;
-s)shift;_vnam="$1";;
-u)_oupc=1;;
-y)_what=0
esac;shift
done
[ -z "$_ofmt" ]&&_text="$*"||printf -v _text "$@"
if [ -z "$_what" ];then
[ "$_info" = - ]&&_info=': '
read -p -r "$_idnt $_text$_info" _repl;CEN_IDNT=1
[ -z "$_repl" ]&&_repl="$_defn"
[ -z "$_oupc" ]&&_repl="${_repl,,}"
[ -n "$_vnam" ]&&printf -v "$_vnam" '%s' "$_repl"
[ -n "$_repl" ];return
fi
local _locy _locn _loqy _loqn _loca=$"yes°no° [Y/n]? ° [y/N]? "
IFS='°' read -r _locy _locn _loqy _loqn <<<"$_loca"
if [ -z "$CEN_YESNO" ];then
if [ "$_what" = 0 ];then
_defn="$_locy";_info="$_loqy"
else
_defn="$_locn";_info="$_loqn"
fi
while :;do
read -rp "$_idnt $_text$_info" _repl;CEN_IDNT=1
_repl="${_repl,,}"
case "${_repl::1}" in
'')  _repl="$_defn";break;;
"${_locn::1}") _repl="$_locn";break;;
"${_locy::1}") _repl="$_locy";break
esac
message -l $"Please enter 'yes' or 'no'"
done
else
[ "$CEN_YESNO" = 'y' ]&&_repl="$_locy"||_repl="$_locn"
fi
[ -n "$_vnam" ]&&printf -v "$_vnam" '%s' "$_repl"
[ "$_repl" = "$_locy" ]
}
create(){
local _rdry _rtru _vnam _fout _darr
while [ "${1::1}" = - ];do
case "$1" in
--)shift;break;;
-c)_vnam='-';;
-r)_rdry='-r';;
-t)_rtru=1;;
-v)shift;_vnam="$1"
esac;shift
done
[ "${1:--}" = - ]&&_fout='/dev/stdout'||_fout="$1"
if [ -z "$_rtru" ]&&[ "${_fout::5}" != '/dev/' ]&&[ -e "$_fout" ];then
trace -c $"Existing file" "$_fout";return 0
fi
dryrun $_rdry $"Create file" "$@"&&return 1
_cen_create_file "$_fout"||return 1
[ -z "$_vnam" ]&&return 0
if [ "$_vnam" = - ];then
local _darr;readarray -t _darr
else
local -n _darr="$_vnam"
fi
printf '%s\n' "${_darr[@]}" >"$_fout"
}
_cen_create_file(){
true >"$1" 2>/dev/null&&return 0;error $"Failed to create file:" "$1"
}
dryrun(){
local _rdry="$CEN_OPT_DRYRUN"
while [ "${1::1}" = - ];do
case "$1" in
--)shift;break;;
-r)_rdry=;;
esac;shift
done
if [ -z "$_rdry" ];then
trace -a -c $"Execute" "$@";return 1
fi
message -a -c $"Skip" "$@";return 0
}
embed(){
local _stat _opts=()
while [ "${1::1}" = - ];do
case "$1" in
--)shift;break;;
-m)return 0;;
-a|-s)_opts+=("$1" "$2");shift;;
-*)_opts+=("$1")
esac;shift
done
_opts+=('--' "$1" '--embed' "$CEN_NAME");shift
[ -n "$CEN_OPT_DRYRUN" ]&&_opts+=('--dryrun')
system -r "${_opts[@]}" "$@";_stat="$?"
[ "$_stat" = 3 ]&&quit -s 3;return "$_stat"
}
folder(){
local _ochg _omak _oerr='error' _oopt='-e -p'
while [ "${1::1}" = - ];do
case "$1" in
--)shift;break;;
-c)_ochg='cd';;
-f)_oerr='fatal';_oopt='-f -p';;
-m)_omak=1;;
-p)_ochg='cd -P';;
-q)_oerr=':';_oopt='-q';;
esac;shift
done
if [ ! -d "$1" ];then
if [ -n "$_omak" ];then
system $_oopt -- mkdir -p "$1"||return 1
else
$_oerr $"Not a folder:" "$1";return 1
fi
fi
[ -z "$_ochg" ]&&return 0
system -r $_oopt -- eval "$_ochg" "$1"||return 1
trace -a -c $"Current folder" "$PWD";return 0
}
splitjoin(){
local _sopt _deli
while [ "${1::1}" = - ];do
case "$1" in
--)shift;break;;
-d)shift;printf -v _deli "$1";;
-s)shift;local -n _vjsx="$1";_sopt=1;;
-j)shift;local -n _vjsx="$1";_sopt=2;;
esac;shift
done
case "$_sopt" in
1)[ -z "$_deli" ]&&_deli=$'\t\n'
local _sifs="$IFS"
set -f;IFS="$_deli" _vjsx=($*);set +f;IFS="$_sifs";;
2)[ -z "$_deli" ]&&_deli=$'\t'
printf -v _vjsx "${_deli::1}%s" "$@";_vjsx="${_vjsx:1}";;
*)return 1
esac;return 0
}
copy(){ _cen_simple_cmd 'cp' "$@";}
rename(){ _cen_simple_cmd 'mv' "$@";}
remove(){ _cen_simple_cmd 'rm' -F "$@";}
symlink(){ _cen_simple_cmd 'ln' -S "$@";}
_cen_simple_cmd(){
local _oerr='-e -p' _orun _args=("$1");shift
while [ "${1::1}" = - ];do
case "$1${_args::1}" in
--?)shift;break;;
-ac)_args+=('-a');;
-uc)_args+=('-u');;
-dr)_args+=('-r');;
-Fr)_args+=('-f');;
-or)_args+=('--one-file-system');;
-nl)_args+=('-f');;
-rl)_args+=('-r');;
-Sl)_args+=('-s');;
-f?)_oerr='-f -p';;
-q?)_oerr='-q';;
-r?)_orun=1;;
esac;shift
done
system $_oerr $_orun -- "${_args[@]}" "$@"
}
system(){
local _stat _rdry _fchk _olou _onam _ored _otyp _odel _oerr=':' _oqui=':'
while [ "${1::1}" = - ];do
case "$1" in
--)shift;break;;
-a)shift;_onam="$1";_ored=1;_otyp=2;;
-c)_fchk=1;;
-d)shift;_odel="$1";;
-e)_oerr='error';_olou='-l';;
-f)_oerr='message -f -l';_olou='-l';_oqui='quit';;
-p)_ored=1;[ -z "$_otyp" ]&&_otyp=0;;
-q)_ored=0;;
-r)_rdry='-r';;
-s)shift;_onam="$1";_ored=1;_otyp=1;;
-t)[ "$CEN_EXIT" = 0 ]||return 1;;
-w)_oerr='warning';;
-z)_ored=2;[ -z "$_otyp" ]&&_otyp=0;;
esac;shift
done
if [ -n "$_fchk" ];then
_stat=0
for _fchk in "$@";do
type -t "$_fchk" &>/dev/null&&continue
$_oerr -p $"Command '%s' not found" "$_fchk";_stat=127;$_oqui
done
return "$_stat"
fi
dryrun $_rdry "$@"&&return 1
[ -n "$_otyp" -a -z "$CEN_TMP_SYSO" ]&&tmpfile -r -s CEN_TMP_SYSO
case "$_ored" in
0)"$@" &>/dev/null;return;;
1)"$@" &>"$CEN_TMP_SYSO";_stat=$?;;
2)"$@" 2>"$CEN_TMP_SYSO";_stat=$?;;
*)"$@";_stat=$?
esac
[ "$_stat" = 0 -a -z "$_onam" ]&&return 0
[ "$_otyp" = 2 ]&&local -n _vsys="$_onam"||local _vsys
[ -n "$_otyp" ]&&readarray -t _vsys <"$CEN_TMP_SYSO"
[ "$_otyp" = 1 ]&&splitjoin -j "$_onam" -- "${_vsys[@]}"
[ "$_stat" = 0 ]&&return 0
CEN_IDNT=;$_oerr -p $"Running '%s' failed (status %s)" "$1" "$_stat"
[ -n "$_otyp" ]&&message -a -m $_olou -- "${_vsys[@]}"
$_oqui;return "$_stat"
}
tmpfile(){
local _vtmp='CEN_TEMPFILE' _rdry _crea=1
local _temp="$CEN_TMP_BASE$CEN_TMP_INDX-$BASHPID"
((CEN_TMP_INDX += 1))
while [ "${1::1}" = - ];do
case "$1" in
-n)_crea=;;
-r)_rdry='-r';;
-s)shift;_vtmp="$1";;
esac;shift
done
printf -v "$_vtmp" '%s' "$_temp"
[ -z "$_crea" ]&&return 0
dryrun $_rdry $"Temporary file" "$_temp"&&return 1
_cen_create_file "$_temp"
}
main(){
if [ "${CEN_NAME:--}" = - ] ;then
CEN_NAME="${BASH_ARGV0##*/}"
CEN_FEATURE_F=1;CEN_FEATURE_Y=1
fi
local _opts=':';PATH=' ' type -t 'options' &>/dev/null&&_opts='options'
while [ "${1::1}" = - ];do
CEN_ARGS=;CEN_ARGOPT=;CEN_ACTION="$1";CEN_ACTARR="$2"
case "$1" in
--*=*)CEN_ARGOPT="${1#*=}";CEN_ACTION="${1%%=*}";;
-[^-]*)CEN_ARGOPT="${1:2}";CEN_ACTION="${1::2}";;
--|---)shift;break;;
esac
$_opts "$CEN_ACTION" "${CEN_ARGOPT:-$2}"
[ -z "$CEN_ARGS" ]&&CEN_ARGS=1&&case "$CEN_ACTION" in
-d|--dry*)CEN_OPT_DRYRUN=1;;
-f|--for*)[ -n "$CEN_FEATURE_F" ]&&CEN_OPT_FORCE=1||CEN_ARGS=0;;
-h|--help)PATH=' ' type -t usage &>/dev/null&&{ usage >&2;quit -s 2;}
quit $"Option '--help' is not implemented";;
-n|--no)[ -n "$CEN_FEATURE_Y" ]&&CEN_YESNO='n'||CEN_ARGS=0;;
-q|--qui*)CEN_VERB=0;;
-v|--ver*)CEN_VERB=2;;
-y|--yes)[ -n "$CEN_FEATURE_Y" ]&&CEN_YESNO='y'||CEN_ARGS=0;;
--embed)optarg - CEN_NAME -t;;
--info)quit -p "mini-bash-lib $CEN_MINI_VERSION; '%s'; %s" "$CEN_VERSION" \
"${CEN_LEGAL:-$"<unknown Author/Licence>"}";;
--mini*);;
--trace)set -x;;
*) CEN_ARGS=
esac
[ "${CEN_ARGS:-0}" -lt 1 ]&&quit -e $"Unknown option:" "$1"
[ "$CEN_ARGS" -gt $# ]&&CEN_ARGS="$#";shift "$CEN_ARGS"
done
CEN_ACTARR=;CEN_ARGOPT=;CEN_ACTION=;$_opts
PATH=' ' type -t run &>/dev/null||return 2;run "$@"
}
optarg(){
local _name="${2:--}" _aarr="$CEN_ACTARR"
[ "$_name" = - ]&&_name="CEN_OPT_${1^^}"
case "${3:--f}" in
-f)printf -v "$_name" '%s' "${4:-1}";CEN_ARGS=1;;
*)if [ -z "$CEN_ARGOPT" ];then
[ "$_aarr" != - ]&&[ -z "$_aarr" -o "${_aarr::1}" = '-' ] &&
quit -e $"Missing option value:" "--$1"
CEN_ARGS=2;CEN_ARGOPT="$_aarr"
else
CEN_ARGS=1
fi
[ "$CEN_ARGOPT" = - ]&&CEN_ARGOPT="${4:--}";printf -v "$_name" '%s' "$CEN_ARGOPT"
esac
}
quit(){
local _opts=() _term
while [ "${1::1}" = - ];do
case "$1" in
-)break;;
--)shift;break;;
-s)shift;CEN_EXIT="$1";;
-e)_term=$"Terminated after error";CEN_EXIT=1;_opts+=('-e');;
-t|-u)_term=$"Terminated";CEN_EXIT=4;;
*)_opts+=("$1");;
esac;shift
done
type -t "$CEN_HOOK_QUIT" &>/dev/null&&"$CEN_HOOK_QUIT" "$@"
if [ -n "$_term" ];then
if [ $# = 0 ];then set -- "$_term"
elif [ "$*" = - ];then set --
elif [ "$1" = - ];then set -- "$_term""${2:+:}" "${@:2}"
fi
fi
[ -n "$*" ]&&message "${_opts[@]}" "$@"
[ "$CEN_TMP_INDX" != 0 -a -n "$CEN_TMP_BASE" ]&&system -q -r -- rm -f "$CEN_TMP_BASE"*
trace -a -c $"Script exits" "STATUS=$CEN_EXIT";exit "$CEN_EXIT"
}
usagecat(){
local _larr _labl _line;readarray -t -u 0 _larr
for _line in "${_larr[@]}";do
[ "$1" = '-l' ]&&{ printf '%s\n' "$_line";continue;}
case "$_line" in
[a-zA-z]*:*) _labl="${_line%%:*}:";_line="${_line#*:}";;
*)_labl=;;
esac
_line="${_line#"${_line%%[![:space:]]*}"}"
printf '%-11s%s\n' "$_labl" "${_line//°/ }"
done
}
command_not_found_handle(){
set +xeE;exec 1>&$CEN_STDOUT 2>&$CEN_STDERR
message -l $"***ABORT***" $"Command not found:" "$1"
kill -42 $$
}
trap 'trap 42; quit -s 127' 42
}
if PATH=' ' type -t run &>/dev/null;then
main "$@";quit
fi
elif [ -n "$CEN_STAGE" ];then
run "$@"
else
main "$@";quit
fi
