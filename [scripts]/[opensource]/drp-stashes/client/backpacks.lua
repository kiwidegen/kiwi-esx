if not StashesConfig.UseBackpacks then return end

--- Initialize backpack vendor
local function initVendor()
  local vendors = lib.callback.await('drp-stashes:server:getVendors', false)
  for k, v in pairs(vendors) do
    lib.requestModel(v.ped)
    local ped = CreatePed(0, v.ped, v.loc.x, v.loc.y, v.loc.z, v.loc.w, false, false)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)

    exports.ox_target:addLocalEntity(ped, {
      {
        label = locale('Vendor.targetLabel'),
        icon = locale('Vendor.targetIcon'),
        onSelect = function()
          local items = lib.callback.await('drp-stashes:server:getBackpacks', false, k)
          local elements = {}

          for itemName, itemData in pairs(items) do
            local itemLabel = exports.ox_inventory:Items(itemName)?.label or itemName
            local itemImage = ('nui://ox_inventory/web/images/%s.png'):format(itemName)

            elements[#elements + 1] = {
              title = itemLabel,
              description = locale('Vendor.price', itemData.price),
              icon = itemImage,
              onSelect = function()
                local input = lib.inputDialog(locale('Vendor.inputTitle'), {
                  {
                    type = 'select',
                    label = locale('Vendor.inputDesc'),
                    options = {
                      {value = 'cash', label = locale('Vendor.inputOption1')},
                      {value = 'bank', label = locale('Vendor.inputOption2')},
                    }
                  }
                })

                if not input then return end
                if not input[1] then return end
                TriggerServerEvent('drp-stashes:server:buyBackpack', k, itemName, input[1])
              end
            }
          end

          lib.registerContext({
            id = 'backpack_vendor_menu',
            title = locale('Vendor.menuTitle'),
            options = elements
          })

          lib.showContext('backpack_vendor_menu')
        end,
      }
    })
  end
end

initVendor()
