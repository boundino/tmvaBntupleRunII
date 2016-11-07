#!/bin/bash

DOTMVA=1
MAKEPLOT=0
MAKEVAR=1

#PTBIN=(7 10)
PTBIN=(15 20 30 50)
#PTBIN=(7 10 15 20 30 50)

COLSYST=('PbPb')
ISPbPb=1
#COLSYST=('pp')
#ISPbPb=0

MVA=('BDT')
#MVA=('CutsSA')
#MVA=('CutsSA' 'CutsGA')
#MVA=('CutsGA' 'CutsSA' 'MLP' 'MLPBFGS' 'MLPBNN' 'BDT' 'BDTG' 'BDTB' 'BDTD' 'BDTMitFisher')
#MVA=('CutsGA' 'CutsSA' 'MLPBNN' 'BDT')

nPT=$((${#PTBIN[@]}-1))
nMVA=${#MVA[@]}
nCOL=${#COLSYST[@]}

# TMVAClassification.C #
if [ $DOTMVA -eq 1 ]; then
    j=0
    while ((j<$nCOL))
    do
        i=0
        while ((i<$nPT))
        do
	    cd myTMVA/
	    echo "-- Processing pT bin: ${PTBIN[i]} - ${PTBIN[i+1]} GeV/c"
	    echo
	    root -l -b -q 'TMVAClassification.C+('$ISPbPb','${PTBIN[i]}','${PTBIN[i+1]}')'
            
	    k=0
	    while ((k<$nMVA))
	    do
	        mv weights/TMVAClassification_${MVA[k]}.weights.xml weights/TMVA_${MVA[k]}_${COLSYST[j]}_${PTBIN[i]}_${PTBIN[i+1]}.weights.xml
	        mv weights/TMVAClassification_${MVA[k]}.class.C weights/TMVA_${MVA[k]}_${COLSYST[j]}_${PTBIN[i]}_${PTBIN[i+1]}.class.C
	        k=$(($k+1))
	    done
	    cd ..
	    i=$(($i+1))    
        done
        j=$(($j+1))
    done    
fi

# Plots #

if [ $MAKEPLOT -eq 1 ]; then
    j=0
    while ((j<$nCOL))
    do
        i=0
        while ((i<$nPT))
        do            
	    cd myTMVA/
	    root -l -b -q 'efficiencies.C("'ROOT/TMVA_${COLSYST[j]}_${PTBIN[i]}_${PTBIN[i+1]}.root'")'
	    root -l -b -q 'mvaeffs.C("'ROOT/TMVA_${COLSYST[j]}_${PTBIN[i]}_${PTBIN[i+1]}.root'")'
	    mv plots/ plots_${COLSYST[j]}_${PTBIN[i]}_${PTBIN[i+1]}/
	    cd ..    
	    i=$(($i+1))
        done
        j=$(($j+1))
    done    
fi

# Tree Variables #

if [ $MAKEVAR -eq 1 ]; then
    k=0
    while ((k<$nMVA))
    do
        j=0
        while ((j<$nCOL))
        do
            i=0
	    while ((i<$nPT))
	    do
		cd mva/
		root -l -b -q 'classmaker.C("'../myTMVA/weights/TMVA_${MVA[k]}_${COLSYST[j]}_${PTBIN[i]}_${PTBIN[i+1]}.class.C'")'
		cd macros/
		root -l -b -q ''${MVA[k]}'.C('$ISPbPb','${PTBIN[i]}','${PTBIN[i+1]}',"'${MVA[k]}'")' 
		cd ../..
	        i=$(($i+1))
	    done
            j=$(($j+1))
        done
        k=$(($k+1))
    done
fi

