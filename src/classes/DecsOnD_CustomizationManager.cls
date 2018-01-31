/**
 * Copyright 2015, Decisions on Demand, Inc.
 * All Rights Reserved.
 * For support, please contact support@decisionsondemand.com
 */
global class DecsOnD_CustomizationManager implements DecsOnD.ICustomizationManager
{
    global Map<String, Object> getCustomizations(String featureName, Map<String, Object> parameters) {
        System.debug(LoggingLevel.debug, 'DecsOnD_CustomizationManager.getCustomizations called for feature ' + featureName);
        if (DecsOnD.AssignmentHelper.class.getName()==featureName) {
            Map<String, Object> values = new Map<String, Object>();
            values.put(DecsOnD.Config.CUSTOMIZATION_FEATURE_APEX_TYPE, CustomAssignmentHelper.class);
            return values;                
        }
        return null;
    }
}