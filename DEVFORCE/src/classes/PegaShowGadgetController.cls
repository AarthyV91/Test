public class PegaShowGadgetController{
public PegaPE.PegaCustomParameters
getPegaCustomParameters()
{
PegaPE.PegaCustomParameters myCustomParameters =
new
PegaPE.PegaCustomParameters();
myCustomParameters.put('UserIdentifier', 'XYZ');
myCustomParameters.put('Password', 'XYZ');
return myCustomParameters;
}
}