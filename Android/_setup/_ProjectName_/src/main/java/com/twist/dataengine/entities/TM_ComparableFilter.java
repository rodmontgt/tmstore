package com.twist.dataengine.entities;

import java.util.List;

public class TM_ComparableFilter {
    public float min_limit;
    public float max_limit;
    public List<TM_ComparableFilterAttribute> attribute;

    public TM_ComparableFilterAttribute getMatchingAttribute(String text) {
        if (attribute != null) {
            for (TM_ComparableFilterAttribute obj : attribute) {
                if (obj.taxo.equals(text))
                    return obj;
            }
        }
        return null;
    }

    public boolean hasAnyOptionInAttribute(String attributeName) {
        if (attribute != null) {
            for (TM_ComparableFilterAttribute attributeItem : attribute) {
                if (attributeItem.taxo.equals(attributeName)) {
                    return !attributeItem.names.isEmpty();
                }
            }
        }
        return false;
    }
}
