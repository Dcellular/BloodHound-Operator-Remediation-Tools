# BloodHoundOperatorRemediationTools
Extensions to BloodHound Operator

Requires BloodHound Operator to use. https://github.com/SadProcessor/BloodHoundOperator

This project uses Git submodules to pull BloodHound Operator as a dependency. If you do not already have BloodHound Operator, you can use the `--recurse-submodules` parameter to include it when cloning this repo (`git clone --recurse-submodules git@github.com:Dcellular/BloodHound-Operator-Remediation-Tools.git`). 

Usage:
- Make sure to have an established session to your BloodHound Enterprise tenant in BloodHound Operator.
- Import with `ipmo ./BHERemediationTools.ps1`
- Run `Get-BHEAceFindingTypes -DomainID '<Domain SID>'.
