ix.option.Add("enableImmersiveFirstPerson", ix.type.bool, false, {
    category = "option.category.firstperson"
})

ix.option.Add("smoothScale", ix.type.number, 0.7, {
    category = "option.category.firstperson",
    min = 0,
    max = 0.9,
    decimals = 1
})

ix.option.Add("customCrosshair", ix.type.bool, true, {
    category = "option.category.firstperson"
})
