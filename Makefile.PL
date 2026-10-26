use ExtUtils::MakeMaker;
WriteMakefile(
    NAME         => 'Games::Dice::Advanced',
    VERSION_FROM => 'lib/Games/Dice/Advanced.pm',
    META_ADD   => {
        license   => 'open_source',
},
META_MERGE => {
        resources => {
            repository => 'https://github.com/DrHyde/perl-modules-Games-Dice-Advanced',
            bugtracker => 'https://github.com/DrHyde/perl-modules-Games-Dice-Advanced/issues'
        }
    },
);
