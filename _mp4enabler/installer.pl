#!/usr/bin/perl

# Aquafox MP4 Enabler
# (C)2019 Cameron Kaiser. (C)2025 wireless.
# Floodgap Free Software License (but the libraries installed are GPL)

# Although you can run this from the shell, it's intended to be a script
# under Platypus. Preprocessed by the Makefile.

use bytes;

$app = "Terminal";

$CP = "/bin/cp";
$PWD = "/bin/pwd";
$OSASCRIPT = "/usr/bin/osascript";
$MACHINE = "/usr/bin/machine";

$FLOC = "Library";
$LFOL = "TenFourFox-FFmpeg";

select(STDOUT); $|++;

chomp($home = `$PWD`);
if ($home =~ /"/) {
	print "Running from a directory with a quote mark in the name.\nIllegal startup location.\n";
	exit;
}

# Check the file architectures. They should all agree.
#     -magic!-+-cpu!-+sub-type
# G4: feedface000000120000000b
# G5: feedface0000001200000064
$buf = '';
if (open(G, "libavcodec.57.dylib")) {
	read(G, $buf, 12);
	$avc = unpack("H*", $buf);
	close(G);
	$buf = '';
}
if (open(G, "libavformat.57.dylib")) {
	read(G, $buf, 12);
	$avf = unpack("H*", $buf);
	close(G);
	$buf = '';
}
if (open(G, "libavutil.55.dylib")) {
	read(G, $buf, 12);
	$avu = unpack("H*", $buf);
	close(G);
	$buf = '';
}
if (length($avc) != 24 || $avc ne $avf || $avf ne $avu || $avc ne $avu) {
	print "The installer appears to be corrupt. Aborting.\n";
	exit;
}

chomp($machine = `$MACHINE`);
if ($machine eq 'ppc970') {
	if ($avc ne 'feedface0000001200000064') {
		print "This installer is for G4 computers over 1.25GHz only.\n";
		exit;
	}
} elsif ($machine eq 'ppc7450') {
	if ($avc ne 'feedface000000120000000b') {
		print "This installer is for G5 computers only.\n";
		exit;
	}
} else {
	print "H.264 video is only supported on Power Macs over 1.25GHz.\n";
	exit;
}

if (!length($ENV{'HOME'}) || !chdir($ENV{'HOME'})) {
	print "The installer can't find your home folder.\n";
	exit;
}

if (!chdir($FLOC)) {
	print "The installer can't find /Library in your home folder.\n";
	exit;
}

$rv = &ascript(<<"EOF");
tell application "$app"
activate
display dialog "Make sure you have quit Aquafox before continuing." buttons ("OK", "Cancel") default button "Cancel"
set answername to button returned of the result
return answername
end tell
EOF
if ($rv ne "OK\n") {
	print "Installation cancelled.\n";
	exit;
}

if (-d $LFOL) {
	$rv = &ascript(<<"EOF");
tell application "$app"
activate
display dialog "Overwrite the existing FFmpeg libraries?" buttons ("OK", "Cancel") default button "Cancel"
set answername to button returned of the result
return answername
end tell
EOF
	if ($rv ne "OK\n") {
		print "Installation cancelled.\n";
		exit;
	}
} elsif (!mkdir($LFOL)) {
	print "Verify permissions to ~/$FLOC.\n";
	print "Unable to create new installation folder.\n";
	exit;
}

if (!chdir($LFOL)) {
	print "Unable to enter installation folder.\n";
	exit;
}

foreach $f
	("libavutil.55.dylib", "libavcodec.57.dylib", "libavformat.57.dylib") {
	if (-e $f) {
		if (!unlink($f)) {
			print "Check permissions to ~/$FLOC/$LFOL.\n";
			print "Unable to remove files prior to install.\n";
			exit;
		}
	}
	system("$CP -p \"$home/$f\" .");
	if (! -e $f) {
		print "Check permissions to ~/$FLOC/$LFOL.\n";
		print "Copy of new libraries failed.\n";
	}
}

print "Successfully installed.\n";
exit;

sub ascript {
	my $what = shift;
	my $buf = '';

	if (open(W, "-|")) {
		while(<W>) {
			$buf .= $_;
		}
		close(W);
		return $buf; # leaving $? in $?
	} else {
		if(open(X, "|$OSASCRIPT")) {
			print X $what;
			close(X);
		}
		$rv = $? >> 8;
		exit $rv;
	}
}

sub unlinkif {
	my $f = shift;
}
