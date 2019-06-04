package com.twist.dataengine.entities;

import java.util.ArrayList;
import java.util.List;

public class TM_Variation_Set extends ArrayList<TM_Variation> {
    public TM_Variation findVariationWithAttributes(List<TM_VariationAttribute> variationAttributes) {
        if (variationAttributes != null && variationAttributes.size() > 0) {
            for (TM_Variation tm_variation : this) {
                if (tm_variation.compareAttributes(variationAttributes))
                    return tm_variation;
            }
        }
        return null;
    }

    public TM_Variation getVariation(int variationId) {
        if (variationId < 0)
            return null;

        for (TM_Variation tm_variation : this) {
            if (tm_variation.id == variationId)
                return tm_variation;

        }
        return null;
    }
}
