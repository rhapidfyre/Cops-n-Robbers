
-- ammu shared config
-- icon 110=nonrange 313=gunrange
--[[

  [] = {
    title   = " Ammunation", icon = 110,
    walkup  = vector3(),
    walkoff = vector3(),
    clerk   = {
      pos = vector3(), h = .0, 
      mdl = GetHashKey("s_m_m_ammucountry")
    }
  },

]]
stores = {
  [1] = {
    title   = "Pillbox Hill Ammunation", icon = 313,
    walkup  = vector3(22.77, -1107.03, 28.597),
    walkoff = vector3(18.08, -1111.14, 29.810),
    range   = vector3(13.53, -1097.36, 29.8347),
    heading = 332.0,
    clerk   = {
      pos = vector3(22.8847, -1105.48, 29.797), h = 151.0,
      mdl = GetHashKey("s_m_y_ammucity_01")
    }
  },
  [2] = {
    title   = "East L.S. Ammunation", icon = 110,
    walkup  = vector3(841.72, -1033.92, 27.701),
    walkoff = vector3(844.42, -1031.24, 28.194),
    clerk   = {
      pos = vector3(842.615, -1035.64, 28.194), h = 350.0,
      mdl = GetHashKey("s_m_y_ammucity_01")
    }
  },
}