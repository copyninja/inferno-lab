#
#	initially generated by c2l
#

implement Seq;

include "draw.m";

Seq: module
{
	init: fn(nil: ref Draw->Context, argl: list of string);
};

include "sys.m";
	sys: Sys;
include "math.m";
	math: Math;
	floor: import math;
include "arg.m";
	arg: Arg;

include "string.m";
	str: String;
min: real = 1.0;
max: real = 0.0;
incr: real = 1.0;
constant: int = 0;
nsteps: int;
format: string;
maxw: int = 0;
maxp: int = 0;

usage()
{
	sys->fprint(sys->fildes(2), "usage: seq [-fw.p] [-w] [first [incr]] last\n");
	exit;
}


buildfmt()
{
	i: int;
	buf :string;

	format = "%g\n";
	if(!constant)
		return;
	maxw = 0;
	maxp = 0;
	for(i = 0; i <= nsteps; i++){
		buf = sys->sprint("%g", min+real i*incr);
		(w, p) := str->splitl(buf, ".");
		if(len w > maxw)
			maxw = len w;
		if((len p - 1) > maxp)
			maxp = len p - 1;
	}
	if(maxp > 0)
		maxw += maxp+1;
#	format = sys->sprint("%%%d.%df\n", maxw, maxp);
}


init(nil: ref Draw->Context, argl: list of string)
{
	sys = load Sys Sys->PATH;
	math = load Math Math->PATH;
	arg = load Arg Arg->PATH;
	str = load String String->PATH;
	i, j: int;
	buf :string;

	arg->init(argl);
	while((c := arg->opt()) != 0)
		case(c){
		'w' =>
			constant++;
		'f' =>
			format = arg->earg();
			(w, p) := str->splitl(format, ".");
			maxw = int w;
			maxp = int p[1:];
			constant++;
		* =>
			;	# TBA was goto out
		}
	argl = arg->argv();
	argc := len argl;
	if(argc < 1 || argc > 3)
		usage();
	if(argc > 1){
		min = real hd argl;
		argl = tl argl;
	}
	if(argc > 2){
		incr = real hd argl;
		argl = tl argl;
	}
	max = real hd argl;
	if(incr == real 0){
		sys->fprint(sys->fildes(2), "seq: zero increment\n");
		exit;
	}
	nsteps = int floor((max-min)/incr+.5);
	if(format == nil)
		buildfmt();
	for(i = 0; i <= nsteps; i++){
		if(constant){
			buf = sys->sprint("%*.*f", maxw, maxp, min+real i*incr);
			for(j = 0; buf[j] ==  ' '; j++)
				buf[j] =  '0';
		}else{
			buf = sys->sprint("%g", min+real i*incr);
		}
		sys->print("%s\n", buf);
	}
	exit;
}

