use ExtUtils::MakeMaker;
WriteMakefile(
		NAME	=> 'Games::Dice::Advanced',
    META_MERGE => {
        license => 'other',
        resource => {
	    repository => 'https://github.com/DrHyde/perl-modules-Games-Dice-Advanced'
        }
    },
		VERSION => '1.1',
		# PREREQ_PM => { Getopt::Declare => 1.09 }
	     );
