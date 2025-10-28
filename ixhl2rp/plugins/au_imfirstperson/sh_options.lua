ix.option.Add("enableImmersiveFirstPerson", ix.type.bool, false, {
    category = "Первое Лицо"
})

ix.option.Add("smoothScale", ix.type.number, 0.7, {
    category = "Первое Лицо",
    min = 0,
    max = 0.9,
    decimals = 1
})

ix.option.Add("customCrosshair", ix.type.bool, true, {
    category = "Первое Лицо"
})
