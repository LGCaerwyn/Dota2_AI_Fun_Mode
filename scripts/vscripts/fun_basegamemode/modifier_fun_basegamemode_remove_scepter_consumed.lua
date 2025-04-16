
--移除特定英雄身上的阿哈利姆福佑，替换为普通神杖的效果,在修饰器过滤器中
function modifier_Fun_BaseGameMode_Remove_Scepter_Consumed(event, result)
       
    local hero = nil
    local modifier_name = nil
    local modifier_1 = "modifier_item_ultimate_scepter"
	local modifier_2 = "modifier_item_ultimate_scepter_consumed"
	local modifier_3 = "modifier_item_ultimate_scepter_consumed_alchemist" 

    if 
        event.entindex_parent_const and 
        event.name_const 
    then
        hero = EntIndexToHScript(event.entindex_parent_const)
        modifier_name = event.name_const      
    end

    if 
        hero
    then
        if 
            (modifier_name == modifier_2 or modifier_name == modifier_2) and
            (hero:HasModifier("modifier_arc_warden_tempest_double") or hero:HasModifier("modifier_monkey_king_fur_army_soldier"))
        then
            --print(" Is Clone")
            hero:RemoveModifierByName(modifier_2)
            hero:RemoveModifierByName(modifier_3)
            hero:AddNewModifier(hero, nil, modifier_1,{})
        end
    end

    return result
end