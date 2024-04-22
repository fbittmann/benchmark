{smcl}
{* *! version 1.0 April 2024}{...}
help for {cmd:benchmark}{right:version 1.0 (April 2024)}
{hline}


{title:Title}

{phang}
{bf:benchmark} {hline 2} Benchmarking Stata


{marker syntax}
{title:Syntax}

{p 8 17 2}
{cmd:benchmark} [, {it:options}]
{p_end}



{marker description}
{title:Description}

{pstd}
{cmd:benchmark} conducts a benchmark analysis of your current machine. By running
eight of Stata's most relevant methods, this gives a rather representative image
of how powerful your current system is. The program runs on a single thread 
(yet might use multiple cores, depending on your Stata license). You can change this
behaviour if desired. Note that this program clears any data in current memory!

    Module 1: Creating random variables
    Module 2: Bootstrapping OLS
    Module 3: Factor analysis (PCA)
    Module 4: Read/Write to disk
    Module 5: Multiple imputation (MICE)
    Module 6: Multilevel analysis
    Module 7: Structural equation modeling (SEM)
    Module 8: Logistic margins (DYDX)



{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opt graph} creates a bar graph to visualize the results.

{phang}
{opt scale} changes the scaling of all benchmarks. The standard is 1.0. Increasing the
number results in more computations done, which is relevant on very fast systems.
Conversely, slower systems, with a very long runtime, can be scaled done. A number
of 0.50 means that each tests cycle is cut down to 50% of the standard computations.

{phang}
{opt singlethread} specifies that only a single system thread is utilized, even if a
Stata MP license is active. This option is useful if you wish to compare systems
that have a different Stata license active.
{p_end}

{marker examples}
{title:Examples}

{phang}Run the benchmarks at 75% of the standard length{p_end}
{phang}{cmd:. benchmark, scale(0.75)}{p_end}


{marker author}
{title:Author}

{pstd}
Felix Bittmann ({browse "mailto:felix.bittmannlifbi.de":felix.bittmann@lifbi.de}), Leibniz Institute for Educational Trajectories (LIfBi), Germany.{break}
{p_end}


