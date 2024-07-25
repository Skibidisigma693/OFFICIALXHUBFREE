--[[
 .____                  ________ ___.    _____                           __                
 |    |    __ _______   \_____  \\_ |___/ ____\_ __  ______ ____ _____ _/  |_  ___________ 
 |    |   |  |  \__  \   /   |   \| __ \   __\  |  \/  ___// ___\\__  \\   __\/  _ \_  __ \
 |    |___|  |  // __ \_/    |    \ \_\ \  | |  |  /\___ \\  \___ / __ \|  | (  <_> )  | \/
 |_______ \____/(____  /\_______  /___  /__| |____//____  >\___  >____  /__|  \____/|__|   
         \/          \/         \/    \/                \/     \/     \/                   
          \_Welcome to LuaObfuscator.com   (Alpha 0.10.6) ~  Much Love, Ferib 

]]--

local StrToNumber = tonumber;
local Byte = string.byte;
local Char = string.char;
local Sub = string.sub;
local Subg = string.gsub;
local Rep = string.rep;
local Concat = table.concat;
local Insert = table.insert;
local LDExp = math.ldexp;
local GetFEnv = getfenv or function()
	return _ENV;
end;
local Setmetatable = setmetatable;
local PCall = pcall;
local Select = select;
local Unpack = unpack or table.unpack;
local ToNumber = tonumber;
local function VMCall(ByteString, vmenv, ...)
	local DIP = 1;
	local repeatNext;
	ByteString = Subg(Sub(ByteString, 5), "..", function(byte)
		if (Byte(byte, 2) == 79) then
			local FlatIdent_7126A = 0;
			while true do
				if (FlatIdent_7126A == 0) then
					repeatNext = StrToNumber(Sub(byte, 1, 1));
					return "";
				end
			end
		else
			local a = Char(StrToNumber(byte, 16));
			if repeatNext then
				local b = Rep(a, repeatNext);
				repeatNext = nil;
				return b;
			else
				return a;
			end
		end
	end);
	local function gBit(Bit, Start, End)
		if End then
			local FlatIdent_12703 = 0;
			local Res;
			while true do
				if (FlatIdent_12703 == 0) then
					Res = (Bit / (2 ^ (Start - 1))) % (2 ^ (((End - 1) - (Start - 1)) + 1));
					return Res - (Res % 1);
				end
			end
		else
			local FlatIdent_2BD95 = 0;
			local Plc;
			while true do
				if (FlatIdent_2BD95 == 0) then
					Plc = 2 ^ (Start - 1);
					return (((Bit % (Plc + Plc)) >= Plc) and 1) or 0;
				end
			end
		end
	end
	local function gBits8()
		local a = Byte(ByteString, DIP, DIP);
		DIP = DIP + 1;
		return a;
	end
	local function gBits16()
		local a, b = Byte(ByteString, DIP, DIP + 2);
		DIP = DIP + 2;
		return (b * 256) + a;
	end
	local function gBits32()
		local a, b, c, d = Byte(ByteString, DIP, DIP + 3);
		DIP = DIP + 4;
		return (d * 16777216) + (c * 65536) + (b * 256) + a;
	end
	local function gFloat()
		local Left = gBits32();
		local Right = gBits32();
		local IsNormal = 1;
		local Mantissa = (gBit(Right, 1, 20) * (2 ^ 32)) + Left;
		local Exponent = gBit(Right, 21, 31);
		local Sign = ((gBit(Right, 32) == 1) and -1) or 1;
		if (Exponent == 0) then
			if (Mantissa == 0) then
				return Sign * 0;
			else
				Exponent = 1;
				IsNormal = 0;
			end
		elseif (Exponent == 2047) then
			return ((Mantissa == 0) and (Sign * (1 / 0))) or (Sign * NaN);
		end
		return LDExp(Sign, Exponent - 1023) * (IsNormal + (Mantissa / (2 ^ 52)));
	end
	local function gString(Len)
		local Str;
		if not Len then
			local FlatIdent_23BE8 = 0;
			while true do
				if (FlatIdent_23BE8 == 0) then
					Len = gBits32();
					if (Len == 0) then
						return "";
					end
					break;
				end
			end
		end
		Str = Sub(ByteString, DIP, (DIP + Len) - 1);
		DIP = DIP + Len;
		local FStr = {};
		for Idx = 1, #Str do
			FStr[Idx] = Char(Byte(Sub(Str, Idx, Idx)));
		end
		return Concat(FStr);
	end
	local gInt = gBits32;
	local function _R(...)
		return {...}, Select("#", ...);
	end
	local function Deserialize()
		local Instrs = {};
		local Functions = {};
		local Lines = {};
		local Chunk = {Instrs,Functions,nil,Lines};
		local ConstCount = gBits32();
		local Consts = {};
		for Idx = 1, ConstCount do
			local Type = gBits8();
			local Cons;
			if (Type == 1) then
				Cons = gBits8() ~= 0;
			elseif (Type == 2) then
				Cons = gFloat();
			elseif (Type == 3) then
				Cons = gString();
			end
			Consts[Idx] = Cons;
		end
		Chunk[3] = gBits8();
		for Idx = 1, gBits32() do
			local FlatIdent_8199B = 0;
			local Descriptor;
			while true do
				if (FlatIdent_8199B == 0) then
					Descriptor = gBits8();
					if (gBit(Descriptor, 1, 1) == 0) then
						local Type = gBit(Descriptor, 2, 3);
						local Mask = gBit(Descriptor, 4, 6);
						local Inst = {gBits16(),gBits16(),nil,nil};
						if (Type == 0) then
							Inst[3] = gBits16();
							Inst[4] = gBits16();
						elseif (Type == 1) then
							Inst[3] = gBits32();
						elseif (Type == 2) then
							Inst[3] = gBits32() - (2 ^ 16);
						elseif (Type == 3) then
							local FlatIdent_39B0 = 0;
							while true do
								if (FlatIdent_39B0 == 0) then
									Inst[3] = gBits32() - (2 ^ 16);
									Inst[4] = gBits16();
									break;
								end
							end
						end
						if (gBit(Mask, 1, 1) == 1) then
							Inst[2] = Consts[Inst[2]];
						end
						if (gBit(Mask, 2, 2) == 1) then
							Inst[3] = Consts[Inst[3]];
						end
						if (gBit(Mask, 3, 3) == 1) then
							Inst[4] = Consts[Inst[4]];
						end
						Instrs[Idx] = Inst;
					end
					break;
				end
			end
		end
		for Idx = 1, gBits32() do
			Functions[Idx - 1] = Deserialize();
		end
		return Chunk;
	end
	local function Wrap(Chunk, Upvalues, Env)
		local Instr = Chunk[1];
		local Proto = Chunk[2];
		local Params = Chunk[3];
		return function(...)
			local Instr = Instr;
			local Proto = Proto;
			local Params = Params;
			local _R = _R;
			local VIP = 1;
			local Top = -1;
			local Vararg = {};
			local Args = {...};
			local PCount = Select("#", ...) - 1;
			local Lupvals = {};
			local Stk = {};
			for Idx = 0, PCount do
				if (Idx >= Params) then
					Vararg[Idx - Params] = Args[Idx + 1];
				else
					Stk[Idx] = Args[Idx + 1];
				end
			end
			local Varargsz = (PCount - Params) + 1;
			local Inst;
			local Enum;
			while true do
				local FlatIdent_1076E = 0;
				while true do
					if (1 == FlatIdent_1076E) then
						if (Enum <= 96) then
							if (Enum <= 47) then
								if (Enum <= 23) then
									if (Enum <= 11) then
										if (Enum <= 5) then
											if (Enum <= 2) then
												if (Enum <= 0) then
													local B;
													local A;
													A = Inst[2];
													Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = {};
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Inst[4];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Inst[4];
												elseif (Enum == 1) then
													local Results;
													local Edx;
													local Results, Limit;
													local B;
													local A;
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Results, Limit = _R(Stk[A](Stk[A + 1]));
													Top = (Limit + A) - 1;
													Edx = 0;
													for Idx = A, Top do
														local FlatIdent_A36C = 0;
														while true do
															if (FlatIdent_A36C == 0) then
																Edx = Edx + 1;
																Stk[Idx] = Results[Edx];
																break;
															end
														end
													end
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Results = {Stk[A](Unpack(Stk, A + 1, Top))};
													Edx = 0;
													for Idx = A, Inst[4] do
														local FlatIdent_7F35E = 0;
														while true do
															if (FlatIdent_7F35E == 0) then
																Edx = Edx + 1;
																Stk[Idx] = Results[Edx];
																break;
															end
														end
													end
													VIP = VIP + 1;
													Inst = Instr[VIP];
													VIP = Inst[3];
												else
													Stk[Inst[2]] = Stk[Inst[3]] ^ Inst[4];
												end
											elseif (Enum <= 3) then
												local A;
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Stk[A + 1]);
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												do
													return;
												end
											elseif (Enum > 4) then
												local FlatIdent_A9A3 = 0;
												while true do
													if (FlatIdent_A9A3 == 0) then
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_A9A3 = 1;
													end
													if (FlatIdent_A9A3 == 3) then
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_A9A3 = 4;
													end
													if (FlatIdent_A9A3 == 2) then
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_A9A3 = 3;
													end
													if (FlatIdent_A9A3 == 1) then
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_A9A3 = 2;
													end
													if (FlatIdent_A9A3 == 4) then
														Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
														break;
													end
												end
											else
												local A = Inst[2];
												do
													return Unpack(Stk, A, A + Inst[3]);
												end
											end
										elseif (Enum <= 8) then
											if (Enum <= 6) then
												local A;
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												VIP = Inst[3];
											elseif (Enum == 7) then
												if (Inst[2] < Stk[Inst[4]]) then
													VIP = VIP + 1;
												else
													VIP = Inst[3];
												end
											else
												local A = Inst[2];
												local B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
											end
										elseif (Enum <= 9) then
											local FlatIdent_1B51D = 0;
											local B;
											local A;
											while true do
												if (FlatIdent_1B51D == 2) then
													A = Inst[2];
													Stk[A] = Stk[A](Stk[A + 1]);
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_1B51D = 3;
												end
												if (FlatIdent_1B51D == 0) then
													B = nil;
													A = nil;
													A = Inst[2];
													B = Stk[Inst[3]];
													FlatIdent_1B51D = 1;
												end
												if (FlatIdent_1B51D == 4) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													FlatIdent_1B51D = 5;
												end
												if (FlatIdent_1B51D == 1) then
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_1B51D = 2;
												end
												if (FlatIdent_1B51D == 5) then
													Inst = Instr[VIP];
													if (Stk[Inst[2]] ~= Stk[Inst[4]]) then
														VIP = VIP + 1;
													else
														VIP = Inst[3];
													end
													break;
												end
												if (FlatIdent_1B51D == 3) then
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													FlatIdent_1B51D = 4;
												end
											end
										elseif (Enum == 10) then
											local FlatIdent_39764 = 0;
											local A;
											while true do
												if (FlatIdent_39764 == 2) then
													Stk[A] = Stk[A](Stk[A + 1]);
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													FlatIdent_39764 = 3;
												end
												if (FlatIdent_39764 == 0) then
													A = nil;
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_39764 = 1;
												end
												if (FlatIdent_39764 == 3) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													FlatIdent_39764 = 4;
												end
												if (1 == FlatIdent_39764) then
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_39764 = 2;
												end
												if (FlatIdent_39764 == 4) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													break;
												end
											end
										else
											local FlatIdent_4CC24 = 0;
											local B;
											local A;
											while true do
												if (FlatIdent_4CC24 == 2) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = {};
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Inst[4];
													FlatIdent_4CC24 = 3;
												end
												if (0 == FlatIdent_4CC24) then
													B = nil;
													A = nil;
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_4CC24 = 1;
												end
												if (1 == FlatIdent_4CC24) then
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_4CC24 = 2;
												end
												if (4 == FlatIdent_4CC24) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Inst[4];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Inst[4];
													FlatIdent_4CC24 = 5;
												end
												if (FlatIdent_4CC24 == 3) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Inst[4];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Inst[4];
													FlatIdent_4CC24 = 4;
												end
												if (FlatIdent_4CC24 == 5) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Inst[4];
													break;
												end
											end
										end
									elseif (Enum <= 17) then
										if (Enum <= 14) then
											if (Enum <= 12) then
												local FlatIdent_49280 = 0;
												while true do
													if (FlatIdent_49280 == 1) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														FlatIdent_49280 = 2;
													end
													if (FlatIdent_49280 == 2) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_49280 = 3;
													end
													if (FlatIdent_49280 == 3) then
														Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
														break;
													end
													if (FlatIdent_49280 == 0) then
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														FlatIdent_49280 = 1;
													end
												end
											elseif (Enum == 13) then
												local Results;
												local Edx;
												local Results, Limit;
												local B;
												local A;
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Results, Limit = _R(Stk[A](Stk[A + 1]));
												Top = (Limit + A) - 1;
												Edx = 0;
												for Idx = A, Top do
													Edx = Edx + 1;
													Stk[Idx] = Results[Edx];
												end
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Results = {Stk[A](Unpack(Stk, A + 1, Top))};
												Edx = 0;
												for Idx = A, Inst[4] do
													Edx = Edx + 1;
													Stk[Idx] = Results[Edx];
												end
												VIP = VIP + 1;
												Inst = Instr[VIP];
												VIP = Inst[3];
											else
												local Results;
												local Edx;
												local Results, Limit;
												local B;
												local A;
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Results, Limit = _R(Stk[A](Stk[A + 1]));
												Top = (Limit + A) - 1;
												Edx = 0;
												for Idx = A, Top do
													Edx = Edx + 1;
													Stk[Idx] = Results[Edx];
												end
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Results = {Stk[A](Unpack(Stk, A + 1, Top))};
												Edx = 0;
												for Idx = A, Inst[4] do
													Edx = Edx + 1;
													Stk[Idx] = Results[Edx];
												end
												VIP = VIP + 1;
												Inst = Instr[VIP];
												VIP = Inst[3];
											end
										elseif (Enum <= 15) then
											if (Stk[Inst[2]] == Inst[4]) then
												VIP = VIP + 1;
											else
												VIP = Inst[3];
											end
										elseif (Enum > 16) then
											local A = Inst[2];
											local Results, Limit = _R(Stk[A](Stk[A + 1]));
											Top = (Limit + A) - 1;
											local Edx = 0;
											for Idx = A, Top do
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
											end
										elseif (Stk[Inst[2]] <= Inst[4]) then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
									elseif (Enum <= 20) then
										if (Enum <= 18) then
											local B;
											local A;
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
										elseif (Enum > 19) then
											local B;
											local T;
											local A;
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											T = Stk[A];
											B = Inst[3];
											for Idx = 1, B do
												T[Idx] = Stk[A + Idx];
											end
										else
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										end
									elseif (Enum <= 21) then
										local B;
										local A;
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										if Stk[Inst[2]] then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
									elseif (Enum > 22) then
										local Results;
										local Edx;
										local Results, Limit;
										local B;
										local A;
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Results, Limit = _R(Stk[A](Stk[A + 1]));
										Top = (Limit + A) - 1;
										Edx = 0;
										for Idx = A, Top do
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
										end
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Results = {Stk[A](Unpack(Stk, A + 1, Top))};
										Edx = 0;
										for Idx = A, Inst[4] do
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
										end
										VIP = VIP + 1;
										Inst = Instr[VIP];
										VIP = Inst[3];
									else
										local FlatIdent_8BC55 = 0;
										local A;
										while true do
											if (1 == FlatIdent_8BC55) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A](Stk[A + 1]);
												FlatIdent_8BC55 = 2;
											end
											if (FlatIdent_8BC55 == 5) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_8BC55 = 6;
											end
											if (FlatIdent_8BC55 == 0) then
												A = nil;
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_8BC55 = 1;
											end
											if (2 == FlatIdent_8BC55) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												FlatIdent_8BC55 = 3;
											end
											if (FlatIdent_8BC55 == 6) then
												Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_8BC55 = 7;
											end
											if (FlatIdent_8BC55 == 4) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												FlatIdent_8BC55 = 5;
											end
											if (FlatIdent_8BC55 == 7) then
												VIP = Inst[3];
												break;
											end
											if (FlatIdent_8BC55 == 3) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												FlatIdent_8BC55 = 4;
											end
										end
									end
								elseif (Enum <= 35) then
									if (Enum <= 29) then
										if (Enum <= 26) then
											if (Enum <= 24) then
												local FlatIdent_32B97 = 0;
												while true do
													if (FlatIdent_32B97 == 3) then
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_32B97 = 4;
													end
													if (FlatIdent_32B97 == 5) then
														VIP = Inst[3];
														break;
													end
													if (FlatIdent_32B97 == 4) then
														Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_32B97 = 5;
													end
													if (FlatIdent_32B97 == 0) then
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_32B97 = 1;
													end
													if (FlatIdent_32B97 == 2) then
														Stk[Inst[2]] = Upvalues[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_32B97 = 3;
													end
													if (FlatIdent_32B97 == 1) then
														Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_32B97 = 2;
													end
												end
											elseif (Enum == 25) then
												Upvalues[Inst[3]] = Stk[Inst[2]];
											else
												local FlatIdent_77172 = 0;
												local A;
												local Results;
												local Limit;
												local Edx;
												while true do
													if (FlatIdent_77172 == 0) then
														A = Inst[2];
														Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
														FlatIdent_77172 = 1;
													end
													if (FlatIdent_77172 == 1) then
														Top = (Limit + A) - 1;
														Edx = 0;
														FlatIdent_77172 = 2;
													end
													if (2 == FlatIdent_77172) then
														for Idx = A, Top do
															local FlatIdent_81225 = 0;
															while true do
																if (FlatIdent_81225 == 0) then
																	Edx = Edx + 1;
																	Stk[Idx] = Results[Edx];
																	break;
																end
															end
														end
														break;
													end
												end
											end
										elseif (Enum <= 27) then
											local B;
											local A;
											A = Inst[2];
											Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
										elseif (Enum == 28) then
											local B;
											local A;
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
										elseif (Stk[Inst[2]] ~= Stk[Inst[4]]) then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
									elseif (Enum <= 32) then
										if (Enum <= 30) then
											Stk[Inst[2]]();
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]]();
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Upvalues[Inst[3]] = Stk[Inst[2]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											VIP = Inst[3];
										elseif (Enum > 31) then
											local A;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
										else
											local FlatIdent_68856 = 0;
											local A;
											while true do
												if (4 == FlatIdent_68856) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													if Stk[Inst[2]] then
														VIP = VIP + 1;
													else
														VIP = Inst[3];
													end
													break;
												end
												if (FlatIdent_68856 == 2) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													FlatIdent_68856 = 3;
												end
												if (FlatIdent_68856 == 3) then
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													FlatIdent_68856 = 4;
												end
												if (FlatIdent_68856 == 0) then
													A = nil;
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													FlatIdent_68856 = 1;
												end
												if (FlatIdent_68856 == 1) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_68856 = 2;
												end
											end
										end
									elseif (Enum <= 33) then
										VIP = Inst[3];
									elseif (Enum > 34) then
										local B;
										local A;
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
									else
										local FlatIdent_912A7 = 0;
										local Edx;
										local Results;
										local B;
										local A;
										while true do
											if (FlatIdent_912A7 == 4) then
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												FlatIdent_912A7 = 5;
											end
											if (FlatIdent_912A7 == 7) then
												Inst = Instr[VIP];
												VIP = Inst[3];
												break;
											end
											if (FlatIdent_912A7 == 5) then
												Inst = Instr[VIP];
												A = Inst[2];
												Results = {Stk[A](Stk[A + 1])};
												FlatIdent_912A7 = 6;
											end
											if (3 == FlatIdent_912A7) then
												Inst = Instr[VIP];
												A = Inst[2];
												B = Stk[Inst[3]];
												FlatIdent_912A7 = 4;
											end
											if (FlatIdent_912A7 == 1) then
												A = nil;
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_912A7 = 2;
											end
											if (FlatIdent_912A7 == 2) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_912A7 = 3;
											end
											if (FlatIdent_912A7 == 6) then
												Edx = 0;
												for Idx = A, Inst[4] do
													Edx = Edx + 1;
													Stk[Idx] = Results[Edx];
												end
												VIP = VIP + 1;
												FlatIdent_912A7 = 7;
											end
											if (FlatIdent_912A7 == 0) then
												Edx = nil;
												Results = nil;
												B = nil;
												FlatIdent_912A7 = 1;
											end
										end
									end
								elseif (Enum <= 41) then
									if (Enum <= 38) then
										if (Enum <= 36) then
											Stk[Inst[2]] = Inst[3];
										elseif (Enum > 37) then
											local FlatIdent_957A4 = 0;
											local A;
											while true do
												if (3 == FlatIdent_957A4) then
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Stk[A + 1]);
													FlatIdent_957A4 = 4;
												end
												if (FlatIdent_957A4 == 5) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													do
														return;
													end
													break;
												end
												if (FlatIdent_957A4 == 4) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													FlatIdent_957A4 = 5;
												end
												if (FlatIdent_957A4 == 2) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													FlatIdent_957A4 = 3;
												end
												if (FlatIdent_957A4 == 0) then
													A = nil;
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													FlatIdent_957A4 = 1;
												end
												if (FlatIdent_957A4 == 1) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													FlatIdent_957A4 = 2;
												end
											end
										else
											local FlatIdent_829F9 = 0;
											local Results;
											local Edx;
											local Limit;
											local A;
											while true do
												if (FlatIdent_829F9 == 4) then
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_829F9 = 5;
												end
												if (FlatIdent_829F9 == 2) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_829F9 = 3;
												end
												if (FlatIdent_829F9 == 3) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A](Stk[A + 1]);
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_829F9 = 4;
												end
												if (FlatIdent_829F9 == 1) then
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A](Stk[A + 1]);
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													FlatIdent_829F9 = 2;
												end
												if (FlatIdent_829F9 == 0) then
													Results = nil;
													Edx = nil;
													Results, Limit = nil;
													A = nil;
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_829F9 = 1;
												end
												if (FlatIdent_829F9 == 5) then
													A = Inst[2];
													Results, Limit = _R(Stk[A]());
													Top = (Limit + A) - 1;
													Edx = 0;
													for Idx = A, Top do
														local FlatIdent_7B2D6 = 0;
														while true do
															if (FlatIdent_7B2D6 == 0) then
																Edx = Edx + 1;
																Stk[Idx] = Results[Edx];
																break;
															end
														end
													end
													VIP = VIP + 1;
													FlatIdent_829F9 = 6;
												end
												if (6 == FlatIdent_829F9) then
													Inst = Instr[VIP];
													A = Inst[2];
													Results = {Stk[A](Unpack(Stk, A + 1, Top))};
													Edx = 0;
													for Idx = A, Inst[4] do
														local FlatIdent_65194 = 0;
														while true do
															if (FlatIdent_65194 == 0) then
																Edx = Edx + 1;
																Stk[Idx] = Results[Edx];
																break;
															end
														end
													end
													break;
												end
											end
										end
									elseif (Enum <= 39) then
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										VIP = Inst[3];
									elseif (Enum > 40) then
										local A;
										A = Inst[2];
										Stk[A] = Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
									else
										Stk[Inst[2]] = Env[Inst[3]];
									end
								elseif (Enum <= 44) then
									if (Enum <= 42) then
										local Results;
										local Edx;
										local Results, Limit;
										local B;
										local A;
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Results, Limit = _R(Stk[A](Stk[A + 1]));
										Top = (Limit + A) - 1;
										Edx = 0;
										for Idx = A, Top do
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
										end
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Results = {Stk[A](Unpack(Stk, A + 1, Top))};
										Edx = 0;
										for Idx = A, Inst[4] do
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
										end
										VIP = VIP + 1;
										Inst = Instr[VIP];
										VIP = Inst[3];
									elseif (Enum > 43) then
										local T;
										local VA;
										local A;
										A = Inst[2];
										Stk[A] = Stk[A]();
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = {};
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Top = (A + Varargsz) - 1;
										for Idx = A, Top do
											VA = Vararg[Idx - A];
											Stk[Idx] = VA;
										end
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										T = Stk[A];
										for Idx = A + 1, Top do
											Insert(T, Stk[Idx]);
										end
									else
										local A = Inst[2];
										Stk[A](Stk[A + 1]);
									end
								elseif (Enum <= 45) then
									local FlatIdent_86E18 = 0;
									while true do
										if (1 == FlatIdent_86E18) then
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_86E18 = 2;
										end
										if (FlatIdent_86E18 == 4) then
											VIP = Inst[3];
											break;
										end
										if (FlatIdent_86E18 == 3) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_86E18 = 4;
										end
										if (2 == FlatIdent_86E18) then
											Upvalues[Inst[3]] = Stk[Inst[2]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_86E18 = 3;
										end
										if (FlatIdent_86E18 == 0) then
											Upvalues[Inst[3]] = Stk[Inst[2]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_86E18 = 1;
										end
									end
								elseif (Enum > 46) then
									local B;
									local A;
									A = Inst[2];
									Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = {};
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								else
									local A;
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									VIP = Inst[3];
								end
							elseif (Enum <= 71) then
								if (Enum <= 59) then
									if (Enum <= 53) then
										if (Enum <= 50) then
											if (Enum <= 48) then
												local FlatIdent_51C44 = 0;
												local A;
												while true do
													if (FlatIdent_51C44 == 0) then
														A = Inst[2];
														do
															return Stk[A](Unpack(Stk, A + 1, Inst[3]));
														end
														break;
													end
												end
											elseif (Enum == 49) then
												local A;
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Stk[A + 1]);
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											else
												local FlatIdent_92514 = 0;
												local A;
												while true do
													if (FlatIdent_92514 == 4) then
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Stk[A + 1]);
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														FlatIdent_92514 = 5;
													end
													if (FlatIdent_92514 == 3) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_92514 = 4;
													end
													if (FlatIdent_92514 == 5) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_92514 = 6;
													end
													if (FlatIdent_92514 == 8) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_92514 = 9;
													end
													if (FlatIdent_92514 == 7) then
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														FlatIdent_92514 = 8;
													end
													if (FlatIdent_92514 == 0) then
														A = nil;
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_92514 = 1;
													end
													if (FlatIdent_92514 == 2) then
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														FlatIdent_92514 = 3;
													end
													if (FlatIdent_92514 == 10) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_92514 = 11;
													end
													if (FlatIdent_92514 == 12) then
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
														FlatIdent_92514 = 13;
													end
													if (FlatIdent_92514 == 9) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														FlatIdent_92514 = 10;
													end
													if (FlatIdent_92514 == 11) then
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														FlatIdent_92514 = 12;
													end
													if (13 == FlatIdent_92514) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														break;
													end
													if (6 == FlatIdent_92514) then
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														FlatIdent_92514 = 7;
													end
													if (FlatIdent_92514 == 1) then
														Stk[Inst[2]] = Upvalues[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														FlatIdent_92514 = 2;
													end
												end
											end
										elseif (Enum <= 51) then
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											if (Stk[Inst[2]] < Stk[Inst[4]]) then
												VIP = VIP + 1;
											else
												VIP = Inst[3];
											end
										elseif (Enum > 52) then
											local FlatIdent_2DB3E = 0;
											local A;
											while true do
												if (FlatIdent_2DB3E == 1) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_2DB3E = 2;
												end
												if (FlatIdent_2DB3E == 5) then
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													VIP = Inst[3];
													break;
												end
												if (4 == FlatIdent_2DB3E) then
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_2DB3E = 5;
												end
												if (FlatIdent_2DB3E == 2) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_2DB3E = 3;
												end
												if (3 == FlatIdent_2DB3E) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_2DB3E = 4;
												end
												if (FlatIdent_2DB3E == 0) then
													A = nil;
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_2DB3E = 1;
												end
											end
										else
											local B;
											local A;
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
										end
									elseif (Enum <= 56) then
										if (Enum <= 54) then
											local A = Inst[2];
											local T = Stk[A];
											local B = Inst[3];
											for Idx = 1, B do
												T[Idx] = Stk[A + Idx];
											end
										elseif (Enum > 55) then
											local A;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
										else
											local Edx;
											local Results, Limit;
											local B;
											local A;
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
											Top = (Limit + A) - 1;
											Edx = 0;
											for Idx = A, Top do
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
											end
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A]();
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
											Top = (Limit + A) - 1;
											Edx = 0;
											for Idx = A, Top do
												local FlatIdent_4D11E = 0;
												while true do
													if (FlatIdent_4D11E == 0) then
														Edx = Edx + 1;
														Stk[Idx] = Results[Edx];
														break;
													end
												end
											end
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A]();
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
											Top = (Limit + A) - 1;
											Edx = 0;
											for Idx = A, Top do
												local FlatIdent_4F2F2 = 0;
												while true do
													if (FlatIdent_4F2F2 == 0) then
														Edx = Edx + 1;
														Stk[Idx] = Results[Edx];
														break;
													end
												end
											end
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A]();
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
										end
									elseif (Enum <= 57) then
										local B;
										local A;
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = {};
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
									elseif (Enum > 58) then
										Env[Inst[3]] = Stk[Inst[2]];
									else
										local B;
										local A;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A](Unpack(Stk, A + 1, Inst[3]));
									end
								elseif (Enum <= 65) then
									if (Enum <= 62) then
										if (Enum <= 60) then
											local FlatIdent_6B9E2 = 0;
											local A;
											while true do
												if (FlatIdent_6B9E2 == 2) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													FlatIdent_6B9E2 = 3;
												end
												if (FlatIdent_6B9E2 == 0) then
													A = nil;
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_6B9E2 = 1;
												end
												if (FlatIdent_6B9E2 == 3) then
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A](Stk[A + 1]);
													VIP = VIP + 1;
													FlatIdent_6B9E2 = 4;
												end
												if (FlatIdent_6B9E2 == 1) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Upvalues[Inst[3]];
													FlatIdent_6B9E2 = 2;
												end
												if (FlatIdent_6B9E2 == 4) then
													Inst = Instr[VIP];
													VIP = Inst[3];
													break;
												end
											end
										elseif (Enum == 61) then
											local B;
											local A;
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
										else
											local B;
											local A;
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]] * Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											VIP = Inst[3];
										end
									elseif (Enum <= 63) then
										local FlatIdent_8CB90 = 0;
										local B;
										local A;
										while true do
											if (8 == FlatIdent_8CB90) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												FlatIdent_8CB90 = 9;
											end
											if (FlatIdent_8CB90 == 9) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_8CB90 = 10;
											end
											if (13 == FlatIdent_8CB90) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												break;
											end
											if (FlatIdent_8CB90 == 0) then
												B = nil;
												A = nil;
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												B = Stk[Inst[3]];
												FlatIdent_8CB90 = 1;
											end
											if (FlatIdent_8CB90 == 12) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_8CB90 = 13;
											end
											if (FlatIdent_8CB90 == 6) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_8CB90 = 7;
											end
											if (FlatIdent_8CB90 == 7) then
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												FlatIdent_8CB90 = 8;
											end
											if (FlatIdent_8CB90 == 1) then
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_8CB90 = 2;
											end
											if (FlatIdent_8CB90 == 3) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												FlatIdent_8CB90 = 4;
											end
											if (FlatIdent_8CB90 == 10) then
												Inst = Instr[VIP];
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_8CB90 = 11;
											end
											if (FlatIdent_8CB90 == 5) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
												VIP = VIP + 1;
												FlatIdent_8CB90 = 6;
											end
											if (FlatIdent_8CB90 == 4) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												FlatIdent_8CB90 = 5;
											end
											if (FlatIdent_8CB90 == 11) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_8CB90 = 12;
											end
											if (2 == FlatIdent_8CB90) then
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_8CB90 = 3;
											end
										end
									elseif (Enum == 64) then
										Stk[Inst[2]]();
									else
										local A;
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									end
								elseif (Enum <= 68) then
									if (Enum <= 66) then
										local B;
										local A;
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									elseif (Enum > 67) then
										local B;
										local A;
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										for Idx = Inst[2], Inst[3] do
											Stk[Idx] = nil;
										end
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										do
											return Stk[A](Unpack(Stk, A + 1, Inst[3]));
										end
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										do
											return Unpack(Stk, A, Top);
										end
										VIP = VIP + 1;
										Inst = Instr[VIP];
										do
											return;
										end
									else
										local B;
										local A;
										A = Inst[2];
										Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = {};
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
									end
								elseif (Enum <= 69) then
									Stk[Inst[2]] = Stk[Inst[3]] * Stk[Inst[4]];
								elseif (Enum == 70) then
									local FlatIdent_1B418 = 0;
									local Edx;
									local Results;
									local A;
									while true do
										if (1 == FlatIdent_1B418) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Results = {Stk[A](Stk[A + 1])};
											FlatIdent_1B418 = 2;
										end
										if (FlatIdent_1B418 == 2) then
											Edx = 0;
											for Idx = A, Inst[4] do
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
											end
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_1B418 = 3;
										end
										if (FlatIdent_1B418 == 4) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											if Stk[Inst[2]] then
												VIP = VIP + 1;
											else
												VIP = Inst[3];
											end
											break;
										end
										if (FlatIdent_1B418 == 0) then
											Edx = nil;
											Results = nil;
											A = nil;
											Stk[Inst[2]] = Upvalues[Inst[3]];
											FlatIdent_1B418 = 1;
										end
										if (FlatIdent_1B418 == 3) then
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											FlatIdent_1B418 = 4;
										end
									end
								else
									local FlatIdent_5013F = 0;
									local Results;
									local Edx;
									local Limit;
									local B;
									local A;
									while true do
										if (FlatIdent_5013F == 2) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_5013F = 3;
										end
										if (FlatIdent_5013F == 4) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_5013F = 5;
										end
										if (1 == FlatIdent_5013F) then
											B = nil;
											A = nil;
											Stk[Inst[2]] = Env[Inst[3]];
											FlatIdent_5013F = 2;
										end
										if (FlatIdent_5013F == 3) then
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											FlatIdent_5013F = 4;
										end
										if (FlatIdent_5013F == 8) then
											for Idx = A, Inst[4] do
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
											end
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_5013F = 9;
										end
										if (FlatIdent_5013F == 6) then
											for Idx = A, Top do
												local FlatIdent_1784A = 0;
												while true do
													if (FlatIdent_1784A == 0) then
														Edx = Edx + 1;
														Stk[Idx] = Results[Edx];
														break;
													end
												end
											end
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_5013F = 7;
										end
										if (0 == FlatIdent_5013F) then
											Results = nil;
											Edx = nil;
											Results, Limit = nil;
											FlatIdent_5013F = 1;
										end
										if (FlatIdent_5013F == 7) then
											A = Inst[2];
											Results = {Stk[A](Unpack(Stk, A + 1, Top))};
											Edx = 0;
											FlatIdent_5013F = 8;
										end
										if (5 == FlatIdent_5013F) then
											Results, Limit = _R(Stk[A](Stk[A + 1]));
											Top = (Limit + A) - 1;
											Edx = 0;
											FlatIdent_5013F = 6;
										end
										if (9 == FlatIdent_5013F) then
											VIP = Inst[3];
											break;
										end
									end
								end
							elseif (Enum <= 83) then
								if (Enum <= 77) then
									if (Enum <= 74) then
										if (Enum <= 72) then
											local B;
											local A;
											A = Inst[2];
											Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
										elseif (Enum == 73) then
											Stk[Inst[2]] = Stk[Inst[3]] / Inst[4];
										else
											local FlatIdent_4E1DE = 0;
											local VA;
											local A;
											while true do
												if (6 == FlatIdent_4E1DE) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													do
														return;
													end
													break;
												end
												if (FlatIdent_4E1DE == 3) then
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
													VIP = VIP + 1;
													FlatIdent_4E1DE = 4;
												end
												if (FlatIdent_4E1DE == 4) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_4E1DE = 5;
												end
												if (FlatIdent_4E1DE == 2) then
													A = Inst[2];
													Top = (A + Varargsz) - 1;
													for Idx = A, Top do
														VA = Vararg[Idx - A];
														Stk[Idx] = VA;
													end
													VIP = VIP + 1;
													FlatIdent_4E1DE = 3;
												end
												if (0 == FlatIdent_4E1DE) then
													VA = nil;
													A = nil;
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													FlatIdent_4E1DE = 1;
												end
												if (FlatIdent_4E1DE == 5) then
													Stk[Inst[2]] = Stk[Inst[3]] + Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													do
														return Stk[Inst[2]];
													end
													FlatIdent_4E1DE = 6;
												end
												if (FlatIdent_4E1DE == 1) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_4E1DE = 2;
												end
											end
										end
									elseif (Enum <= 75) then
										local B;
										local A;
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										Inst = Instr[VIP];
										for Idx = Inst[2], Inst[3] do
											Stk[Idx] = nil;
										end
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Env[Inst[3]] = Stk[Inst[2]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										VIP = Inst[3];
									elseif (Enum == 76) then
										local A;
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										VIP = Inst[3];
									else
										local B = Stk[Inst[4]];
										if B then
											VIP = VIP + 1;
										else
											Stk[Inst[2]] = B;
											VIP = Inst[3];
										end
									end
								elseif (Enum <= 80) then
									if (Enum <= 78) then
										local FlatIdent_185A5 = 0;
										local B;
										local A;
										while true do
											if (FlatIdent_185A5 == 6) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												break;
											end
											if (FlatIdent_185A5 == 5) then
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_185A5 = 6;
											end
											if (FlatIdent_185A5 == 3) then
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												FlatIdent_185A5 = 4;
											end
											if (FlatIdent_185A5 == 1) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_185A5 = 2;
											end
											if (FlatIdent_185A5 == 2) then
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_185A5 = 3;
											end
											if (FlatIdent_185A5 == 4) then
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_185A5 = 5;
											end
											if (FlatIdent_185A5 == 0) then
												B = nil;
												A = nil;
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												FlatIdent_185A5 = 1;
											end
										end
									elseif (Enum > 79) then
										local B;
										local A;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]] + Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]] * Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]] + Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]] ^ Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] * Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]] + Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]] / Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = -Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]] / Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]] * Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									else
										local FlatIdent_6B92D = 0;
										local VA;
										local A;
										while true do
											if (FlatIdent_6B92D == 6) then
												do
													return Unpack(Stk, A, Top);
												end
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_6B92D = 7;
											end
											if (3 == FlatIdent_6B92D) then
												Top = (A + Varargsz) - 1;
												for Idx = A, Top do
													VA = Vararg[Idx - A];
													Stk[Idx] = VA;
												end
												VIP = VIP + 1;
												FlatIdent_6B92D = 4;
											end
											if (FlatIdent_6B92D == 7) then
												VIP = Inst[3];
												break;
											end
											if (FlatIdent_6B92D == 2) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_6B92D = 3;
											end
											if (FlatIdent_6B92D == 0) then
												VA = nil;
												A = nil;
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_6B92D = 1;
											end
											if (FlatIdent_6B92D == 1) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												FlatIdent_6B92D = 2;
											end
											if (4 == FlatIdent_6B92D) then
												Inst = Instr[VIP];
												A = Inst[2];
												do
													return Stk[A](Unpack(Stk, A + 1, Top));
												end
												FlatIdent_6B92D = 5;
											end
											if (FlatIdent_6B92D == 5) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_6B92D = 6;
											end
										end
									end
								elseif (Enum <= 81) then
									local FlatIdent_6719E = 0;
									local NewProto;
									local NewUvals;
									local Indexes;
									while true do
										if (FlatIdent_6719E == 1) then
											Indexes = {};
											NewUvals = Setmetatable({}, {__index=function(_, Key)
												local FlatIdent_28E8A = 0;
												local Val;
												while true do
													if (FlatIdent_28E8A == 0) then
														Val = Indexes[Key];
														return Val[1][Val[2]];
													end
												end
											end,__newindex=function(_, Key, Value)
												local Val = Indexes[Key];
												Val[1][Val[2]] = Value;
											end});
											FlatIdent_6719E = 2;
										end
										if (FlatIdent_6719E == 2) then
											for Idx = 1, Inst[4] do
												VIP = VIP + 1;
												local Mvm = Instr[VIP];
												if (Mvm[1] == 106) then
													Indexes[Idx - 1] = {Stk,Mvm[3]};
												else
													Indexes[Idx - 1] = {Upvalues,Mvm[3]};
												end
												Lupvals[#Lupvals + 1] = Indexes;
											end
											Stk[Inst[2]] = Wrap(NewProto, NewUvals, Env);
											break;
										end
										if (FlatIdent_6719E == 0) then
											NewProto = Proto[Inst[3]];
											NewUvals = nil;
											FlatIdent_6719E = 1;
										end
									end
								elseif (Enum > 82) then
									Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
								elseif (Stk[Inst[2]] < Stk[Inst[4]]) then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							elseif (Enum <= 89) then
								if (Enum <= 86) then
									if (Enum <= 84) then
										local A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									elseif (Enum > 85) then
										local Edx;
										local Results;
										local B;
										local A;
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Results = {Stk[A](Stk[A + 1])};
										Edx = 0;
										for Idx = A, Inst[4] do
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
										end
										VIP = VIP + 1;
										Inst = Instr[VIP];
										VIP = Inst[3];
									elseif (Stk[Inst[2]] ~= Inst[4]) then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								elseif (Enum <= 87) then
									local B;
									local A;
									A = Inst[2];
									Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									VIP = Inst[3];
								elseif (Enum == 88) then
									local FlatIdent_8751C = 0;
									local B;
									local A;
									while true do
										if (5 == FlatIdent_8751C) then
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_8751C = 6;
										end
										if (3 == FlatIdent_8751C) then
											Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_8751C = 4;
										end
										if (FlatIdent_8751C == 1) then
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_8751C = 2;
										end
										if (FlatIdent_8751C == 4) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											FlatIdent_8751C = 5;
										end
										if (FlatIdent_8751C == 0) then
											B = nil;
											A = nil;
											A = Inst[2];
											B = Stk[Inst[3]];
											FlatIdent_8751C = 1;
										end
										if (FlatIdent_8751C == 6) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											FlatIdent_8751C = 7;
										end
										if (2 == FlatIdent_8751C) then
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_8751C = 3;
										end
										if (FlatIdent_8751C == 7) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											FlatIdent_8751C = 8;
										end
										if (FlatIdent_8751C == 8) then
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_8751C = 9;
										end
										if (FlatIdent_8751C == 9) then
											Stk[Inst[2]][Inst[3]] = Inst[4];
											break;
										end
									end
								else
									local FlatIdent_D6BD = 0;
									local B;
									local A;
									while true do
										if (FlatIdent_D6BD == 2) then
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_D6BD = 3;
										end
										if (FlatIdent_D6BD == 4) then
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_D6BD = 5;
										end
										if (FlatIdent_D6BD == 8) then
											Stk[Inst[2]][Inst[3]] = Inst[4];
											break;
										end
										if (FlatIdent_D6BD == 7) then
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_D6BD = 8;
										end
										if (FlatIdent_D6BD == 1) then
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											FlatIdent_D6BD = 2;
										end
										if (FlatIdent_D6BD == 0) then
											B = nil;
											A = nil;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											FlatIdent_D6BD = 1;
										end
										if (FlatIdent_D6BD == 5) then
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											FlatIdent_D6BD = 6;
										end
										if (FlatIdent_D6BD == 3) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											FlatIdent_D6BD = 4;
										end
										if (FlatIdent_D6BD == 6) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											FlatIdent_D6BD = 7;
										end
									end
								end
							elseif (Enum <= 92) then
								if (Enum <= 90) then
									local B;
									local A;
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									VIP = Inst[3];
								elseif (Enum > 91) then
									do
										return Stk[Inst[2]];
									end
								else
									Upvalues[Inst[3]] = Stk[Inst[2]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3] ~= 0;
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Upvalues[Inst[3]] = Stk[Inst[2]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									VIP = Inst[3];
								end
							elseif (Enum <= 94) then
								if (Enum == 93) then
									local A = Inst[2];
									local T = Stk[A];
									for Idx = A + 1, Top do
										Insert(T, Stk[Idx]);
									end
								else
									local A;
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									VIP = Inst[3];
								end
							elseif (Enum > 95) then
								Stk[Inst[2]] = -Stk[Inst[3]];
							else
								local DIP;
								local NStk;
								local Upv;
								local List;
								local Cls;
								local B;
								local A;
								A = Inst[2];
								Stk[A](Stk[A + 1]);
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A](Stk[A + 1]);
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Cls = {};
								for Idx = 1, #Lupvals do
									local FlatIdent_5B0A0 = 0;
									while true do
										if (FlatIdent_5B0A0 == 0) then
											List = Lupvals[Idx];
											for Idz = 0, #List do
												local FlatIdent_9128B = 0;
												while true do
													if (FlatIdent_9128B == 1) then
														DIP = Upv[2];
														if ((NStk == Stk) and (DIP >= A)) then
															Cls[DIP] = NStk[DIP];
															Upv[1] = Cls;
														end
														break;
													end
													if (FlatIdent_9128B == 0) then
														Upv = List[Idz];
														NStk = Upv[1];
														FlatIdent_9128B = 1;
													end
												end
											end
											break;
										end
									end
								end
								VIP = VIP + 1;
								Inst = Instr[VIP];
								VIP = Inst[3];
							end
						elseif (Enum <= 144) then
							if (Enum <= 120) then
								if (Enum <= 108) then
									if (Enum <= 102) then
										if (Enum <= 99) then
											if (Enum <= 97) then
												Stk[Inst[2]] = Upvalues[Inst[3]];
											elseif (Enum == 98) then
												local Results;
												local Edx;
												local Results, Limit;
												local B;
												local A;
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Results, Limit = _R(Stk[A](Stk[A + 1]));
												Top = (Limit + A) - 1;
												Edx = 0;
												for Idx = A, Top do
													Edx = Edx + 1;
													Stk[Idx] = Results[Edx];
												end
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Results = {Stk[A](Unpack(Stk, A + 1, Top))};
												Edx = 0;
												for Idx = A, Inst[4] do
													Edx = Edx + 1;
													Stk[Idx] = Results[Edx];
												end
												VIP = VIP + 1;
												Inst = Instr[VIP];
												VIP = Inst[3];
											else
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											end
										elseif (Enum <= 100) then
											local B;
											local A;
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
										elseif (Enum == 101) then
											local FlatIdent_1FAE6 = 0;
											local B;
											local A;
											while true do
												if (FlatIdent_1FAE6 == 26) then
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Inst[4];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													FlatIdent_1FAE6 = 27;
												end
												if (FlatIdent_1FAE6 == 13) then
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_1FAE6 = 14;
												end
												if (FlatIdent_1FAE6 == 20) then
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Inst[4];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Inst[4];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_1FAE6 = 21;
												end
												if (FlatIdent_1FAE6 == 8) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Stk[A + 1]);
													FlatIdent_1FAE6 = 9;
												end
												if (17 == FlatIdent_1FAE6) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Inst[4];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													FlatIdent_1FAE6 = 18;
												end
												if (1 == FlatIdent_1FAE6) then
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_1FAE6 = 2;
												end
												if (FlatIdent_1FAE6 == 24) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													FlatIdent_1FAE6 = 25;
												end
												if (FlatIdent_1FAE6 == 16) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													FlatIdent_1FAE6 = 17;
												end
												if (FlatIdent_1FAE6 == 5) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Stk[A + 1]);
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_1FAE6 = 6;
												end
												if (FlatIdent_1FAE6 == 9) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													FlatIdent_1FAE6 = 10;
												end
												if (22 == FlatIdent_1FAE6) then
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													FlatIdent_1FAE6 = 23;
												end
												if (3 == FlatIdent_1FAE6) then
													Inst = Instr[VIP];
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_1FAE6 = 4;
												end
												if (FlatIdent_1FAE6 == 18) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_1FAE6 = 19;
												end
												if (FlatIdent_1FAE6 == 2) then
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													FlatIdent_1FAE6 = 3;
												end
												if (FlatIdent_1FAE6 == 27) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Stk[A + 1]);
													FlatIdent_1FAE6 = 28;
												end
												if (FlatIdent_1FAE6 == 7) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													FlatIdent_1FAE6 = 8;
												end
												if (FlatIdent_1FAE6 == 11) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_1FAE6 = 12;
												end
												if (19 == FlatIdent_1FAE6) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_1FAE6 = 20;
												end
												if (FlatIdent_1FAE6 == 15) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_1FAE6 = 16;
												end
												if (FlatIdent_1FAE6 == 12) then
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_1FAE6 = 13;
												end
												if (28 == FlatIdent_1FAE6) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													break;
												end
												if (25 == FlatIdent_1FAE6) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													FlatIdent_1FAE6 = 26;
												end
												if (14 == FlatIdent_1FAE6) then
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													FlatIdent_1FAE6 = 15;
												end
												if (10 == FlatIdent_1FAE6) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_1FAE6 = 11;
												end
												if (0 == FlatIdent_1FAE6) then
													B = nil;
													A = nil;
													A = Inst[2];
													Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_1FAE6 = 1;
												end
												if (FlatIdent_1FAE6 == 6) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Stk[A + 1]);
													VIP = VIP + 1;
													FlatIdent_1FAE6 = 7;
												end
												if (FlatIdent_1FAE6 == 4) then
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													FlatIdent_1FAE6 = 5;
												end
												if (FlatIdent_1FAE6 == 23) then
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Inst[4];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													FlatIdent_1FAE6 = 24;
												end
												if (21 == FlatIdent_1FAE6) then
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_1FAE6 = 22;
												end
											end
										else
											local A = Inst[2];
											local Cls = {};
											for Idx = 1, #Lupvals do
												local List = Lupvals[Idx];
												for Idz = 0, #List do
													local FlatIdent_771FD = 0;
													local Upv;
													local NStk;
													local DIP;
													while true do
														if (1 == FlatIdent_771FD) then
															DIP = Upv[2];
															if ((NStk == Stk) and (DIP >= A)) then
																local FlatIdent_821F1 = 0;
																while true do
																	if (0 == FlatIdent_821F1) then
																		Cls[DIP] = NStk[DIP];
																		Upv[1] = Cls;
																		break;
																	end
																end
															end
															break;
														end
														if (FlatIdent_771FD == 0) then
															Upv = List[Idz];
															NStk = Upv[1];
															FlatIdent_771FD = 1;
														end
													end
												end
											end
										end
									elseif (Enum <= 105) then
										if (Enum <= 103) then
											local B;
											local A;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
										elseif (Enum == 104) then
											local FlatIdent_4479E = 0;
											while true do
												if (FlatIdent_4479E == 1) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_4479E = 2;
												end
												if (FlatIdent_4479E == 2) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_4479E = 3;
												end
												if (FlatIdent_4479E == 0) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_4479E = 1;
												end
												if (FlatIdent_4479E == 4) then
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													break;
												end
												if (FlatIdent_4479E == 3) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_4479E = 4;
												end
											end
										else
											local FlatIdent_885BC = 0;
											local B;
											local A;
											while true do
												if (FlatIdent_885BC == 1) then
													Stk[A] = B[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_885BC = 2;
												end
												if (FlatIdent_885BC == 4) then
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													FlatIdent_885BC = 5;
												end
												if (FlatIdent_885BC == 5) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_885BC = 6;
												end
												if (FlatIdent_885BC == 3) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Inst[4];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_885BC = 4;
												end
												if (FlatIdent_885BC == 0) then
													B = nil;
													A = nil;
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													FlatIdent_885BC = 1;
												end
												if (FlatIdent_885BC == 6) then
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													VIP = Inst[3];
													break;
												end
												if (FlatIdent_885BC == 2) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = {};
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Inst[4];
													FlatIdent_885BC = 3;
												end
											end
										end
									elseif (Enum <= 106) then
										Stk[Inst[2]] = Stk[Inst[3]];
									elseif (Enum > 107) then
										for Idx = Inst[2], Inst[3] do
											Stk[Idx] = nil;
										end
									else
										local B;
										local A;
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
									end
								elseif (Enum <= 114) then
									if (Enum <= 111) then
										if (Enum <= 109) then
											local A;
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
										elseif (Enum > 110) then
											local FlatIdent_2CB11 = 0;
											local B;
											local A;
											while true do
												if (FlatIdent_2CB11 == 0) then
													B = nil;
													A = nil;
													A = Inst[2];
													B = Stk[Inst[3]];
													FlatIdent_2CB11 = 1;
												end
												if (FlatIdent_2CB11 == 6) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Inst[4];
													VIP = VIP + 1;
													FlatIdent_2CB11 = 7;
												end
												if (FlatIdent_2CB11 == 3) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Inst[4];
													VIP = VIP + 1;
													FlatIdent_2CB11 = 4;
												end
												if (FlatIdent_2CB11 == 5) then
													Stk[Inst[2]][Inst[3]] = Inst[4];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Inst[4];
													FlatIdent_2CB11 = 6;
												end
												if (FlatIdent_2CB11 == 1) then
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_2CB11 = 2;
												end
												if (FlatIdent_2CB11 == 4) then
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Inst[4];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_2CB11 = 5;
												end
												if (FlatIdent_2CB11 == 2) then
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = {};
													FlatIdent_2CB11 = 3;
												end
												if (7 == FlatIdent_2CB11) then
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Inst[4];
													break;
												end
											end
										else
											local FlatIdent_57195 = 0;
											local Edx;
											local Results;
											local B;
											local A;
											while true do
												if (FlatIdent_57195 == 0) then
													Edx = nil;
													Results = nil;
													B = nil;
													FlatIdent_57195 = 1;
												end
												if (FlatIdent_57195 == 8) then
													Inst = Instr[VIP];
													VIP = Inst[3];
													break;
												end
												if (FlatIdent_57195 == 5) then
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													VIP = VIP + 1;
													FlatIdent_57195 = 6;
												end
												if (FlatIdent_57195 == 4) then
													Inst = Instr[VIP];
													A = Inst[2];
													B = Stk[Inst[3]];
													FlatIdent_57195 = 5;
												end
												if (FlatIdent_57195 == 2) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													FlatIdent_57195 = 3;
												end
												if (FlatIdent_57195 == 3) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													FlatIdent_57195 = 4;
												end
												if (FlatIdent_57195 == 6) then
													Inst = Instr[VIP];
													A = Inst[2];
													Results = {Stk[A](Stk[A + 1])};
													FlatIdent_57195 = 7;
												end
												if (1 == FlatIdent_57195) then
													A = nil;
													Upvalues[Inst[3]] = Stk[Inst[2]];
													VIP = VIP + 1;
													FlatIdent_57195 = 2;
												end
												if (7 == FlatIdent_57195) then
													Edx = 0;
													for Idx = A, Inst[4] do
														Edx = Edx + 1;
														Stk[Idx] = Results[Edx];
													end
													VIP = VIP + 1;
													FlatIdent_57195 = 8;
												end
											end
										end
									elseif (Enum <= 112) then
										local FlatIdent_92B2B = 0;
										while true do
											if (FlatIdent_92B2B == 1) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_92B2B = 2;
											end
											if (FlatIdent_92B2B == 0) then
												Stk[Inst[2]] = {};
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_92B2B = 1;
											end
											if (FlatIdent_92B2B == 4) then
												VIP = Inst[3];
												break;
											end
											if (FlatIdent_92B2B == 2) then
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_92B2B = 3;
											end
											if (FlatIdent_92B2B == 3) then
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_92B2B = 4;
											end
										end
									elseif (Enum > 113) then
										local A = Inst[2];
										do
											return Stk[A](Unpack(Stk, A + 1, Top));
										end
									else
										local A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
									end
								elseif (Enum <= 117) then
									if (Enum <= 115) then
										local A = Inst[2];
										local T = Stk[A];
										for Idx = A + 1, Inst[3] do
											Insert(T, Stk[Idx]);
										end
									elseif (Enum == 116) then
										Stk[Inst[2]][Inst[3]] = Inst[4];
									else
										local A;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										Inst = Instr[VIP];
										if (Stk[Inst[2]] < Stk[Inst[4]]) then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
									end
								elseif (Enum <= 118) then
									local A = Inst[2];
									local Results = {Stk[A](Unpack(Stk, A + 1, Top))};
									local Edx = 0;
									for Idx = A, Inst[4] do
										Edx = Edx + 1;
										Stk[Idx] = Results[Edx];
									end
								elseif (Enum == 119) then
									local A = Inst[2];
									local Results = {Stk[A](Stk[A + 1])};
									local Edx = 0;
									for Idx = A, Inst[4] do
										local FlatIdent_2644E = 0;
										while true do
											if (FlatIdent_2644E == 0) then
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
												break;
											end
										end
									end
								else
									local FlatIdent_384E6 = 0;
									local B;
									local A;
									while true do
										if (FlatIdent_384E6 == 5) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											break;
										end
										if (FlatIdent_384E6 == 1) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											FlatIdent_384E6 = 2;
										end
										if (3 == FlatIdent_384E6) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_384E6 = 4;
										end
										if (FlatIdent_384E6 == 4) then
											Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											FlatIdent_384E6 = 5;
										end
										if (FlatIdent_384E6 == 0) then
											B = nil;
											A = nil;
											A = Inst[2];
											Stk[A](Unpack(Stk, A + 1, Inst[3]));
											FlatIdent_384E6 = 1;
										end
										if (2 == FlatIdent_384E6) then
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_384E6 = 3;
										end
									end
								end
							elseif (Enum <= 132) then
								if (Enum <= 126) then
									if (Enum <= 123) then
										if (Enum <= 121) then
											local A = Inst[2];
											Stk[A](Unpack(Stk, A + 1, Inst[3]));
										elseif (Enum == 122) then
											Stk[Inst[2]] = #Stk[Inst[3]];
										else
											local B;
											local A;
											A = Inst[2];
											Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
										end
									elseif (Enum <= 124) then
										local A;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										Inst = Instr[VIP];
										VIP = Inst[3];
									elseif (Enum == 125) then
										local FlatIdent_8671A = 0;
										local B;
										local A;
										while true do
											if (FlatIdent_8671A == 8) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_8671A = 9;
											end
											if (FlatIdent_8671A == 2) then
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_8671A = 3;
											end
											if (FlatIdent_8671A == 7) then
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												FlatIdent_8671A = 8;
											end
											if (FlatIdent_8671A == 6) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_8671A = 7;
											end
											if (FlatIdent_8671A == 1) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_8671A = 2;
											end
											if (FlatIdent_8671A == 3) then
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_8671A = 4;
											end
											if (FlatIdent_8671A == 4) then
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												FlatIdent_8671A = 5;
											end
											if (FlatIdent_8671A == 0) then
												B = nil;
												A = nil;
												Stk[Inst[2]] = Inst[3];
												FlatIdent_8671A = 1;
											end
											if (FlatIdent_8671A == 5) then
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_8671A = 6;
											end
											if (FlatIdent_8671A == 9) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												break;
											end
										end
									else
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										if Stk[Inst[2]] then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
									end
								elseif (Enum <= 129) then
									if (Enum <= 127) then
										local FlatIdent_94DD1 = 0;
										local A;
										while true do
											if (FlatIdent_94DD1 == 3) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_94DD1 = 4;
											end
											if (FlatIdent_94DD1 == 2) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_94DD1 = 3;
											end
											if (FlatIdent_94DD1 == 0) then
												A = nil;
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_94DD1 = 1;
											end
											if (FlatIdent_94DD1 == 1) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_94DD1 = 2;
											end
											if (5 == FlatIdent_94DD1) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												FlatIdent_94DD1 = 6;
											end
											if (FlatIdent_94DD1 == 4) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												FlatIdent_94DD1 = 5;
											end
											if (FlatIdent_94DD1 == 6) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												if (Stk[Inst[2]] <= Inst[4]) then
													VIP = VIP + 1;
												else
													VIP = Inst[3];
												end
												break;
											end
										end
									elseif (Enum == 128) then
										local A;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										if Stk[Inst[2]] then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
									else
										local Edx;
										local Results, Limit;
										local B;
										local A;
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
										Top = (Limit + A) - 1;
										Edx = 0;
										for Idx = A, Top do
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
										end
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										if (Stk[Inst[2]] == Inst[4]) then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
									end
								elseif (Enum <= 130) then
									local FlatIdent_1435C = 0;
									local A;
									while true do
										if (FlatIdent_1435C == 2) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_1435C = 3;
										end
										if (FlatIdent_1435C == 4) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											break;
										end
										if (FlatIdent_1435C == 1) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_1435C = 2;
										end
										if (3 == FlatIdent_1435C) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A](Stk[A + 1]);
											FlatIdent_1435C = 4;
										end
										if (FlatIdent_1435C == 0) then
											A = nil;
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											FlatIdent_1435C = 1;
										end
									end
								elseif (Enum > 131) then
									local FlatIdent_24BE7 = 0;
									local B;
									while true do
										if (FlatIdent_24BE7 == 0) then
											B = Stk[Inst[4]];
											if not B then
												VIP = VIP + 1;
											else
												local FlatIdent_900D9 = 0;
												while true do
													if (FlatIdent_900D9 == 0) then
														Stk[Inst[2]] = B;
														VIP = Inst[3];
														break;
													end
												end
											end
											break;
										end
									end
								else
									local FlatIdent_568D2 = 0;
									local A;
									while true do
										if (FlatIdent_568D2 == 3) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_568D2 = 4;
										end
										if (FlatIdent_568D2 == 2) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A](Unpack(Stk, A + 1, Inst[3]));
											FlatIdent_568D2 = 3;
										end
										if (FlatIdent_568D2 == 1) then
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											FlatIdent_568D2 = 2;
										end
										if (FlatIdent_568D2 == 4) then
											Inst = Instr[VIP];
											VIP = Inst[3];
											break;
										end
										if (FlatIdent_568D2 == 0) then
											A = nil;
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_568D2 = 1;
										end
									end
								end
							elseif (Enum <= 138) then
								if (Enum <= 135) then
									if (Enum <= 133) then
										local FlatIdent_93859 = 0;
										while true do
											if (FlatIdent_93859 == 2) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_93859 = 3;
											end
											if (1 == FlatIdent_93859) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_93859 = 2;
											end
											if (FlatIdent_93859 == 0) then
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_93859 = 1;
											end
											if (FlatIdent_93859 == 6) then
												if Stk[Inst[2]] then
													VIP = VIP + 1;
												else
													VIP = Inst[3];
												end
												break;
											end
											if (FlatIdent_93859 == 3) then
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_93859 = 4;
											end
											if (4 == FlatIdent_93859) then
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_93859 = 5;
											end
											if (FlatIdent_93859 == 5) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_93859 = 6;
											end
										end
									elseif (Enum == 134) then
										local FlatIdent_4E54D = 0;
										local B;
										local A;
										while true do
											if (FlatIdent_4E54D == 1) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												FlatIdent_4E54D = 2;
											end
											if (FlatIdent_4E54D == 2) then
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_4E54D = 3;
											end
											if (FlatIdent_4E54D == 0) then
												B = nil;
												A = nil;
												A = Inst[2];
												Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_4E54D = 1;
											end
											if (FlatIdent_4E54D == 4) then
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												FlatIdent_4E54D = 5;
											end
											if (FlatIdent_4E54D == 5) then
												Inst = Instr[VIP];
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												break;
											end
											if (FlatIdent_4E54D == 3) then
												Stk[Inst[2]] = {};
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_4E54D = 4;
											end
										end
									else
										local Edx;
										local Results, Limit;
										local B;
										local A;
										A = Inst[2];
										Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = {};
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
										Top = (Limit + A) - 1;
										Edx = 0;
										for Idx = A, Top do
											local FlatIdent_683D2 = 0;
											while true do
												if (FlatIdent_683D2 == 0) then
													Edx = Edx + 1;
													Stk[Idx] = Results[Edx];
													break;
												end
											end
										end
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
										Top = (Limit + A) - 1;
										Edx = 0;
										for Idx = A, Top do
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
										end
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
										Top = (Limit + A) - 1;
										Edx = 0;
										for Idx = A, Top do
											local FlatIdent_9876 = 0;
											while true do
												if (FlatIdent_9876 == 0) then
													Edx = Edx + 1;
													Stk[Idx] = Results[Edx];
													break;
												end
											end
										end
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
										Top = (Limit + A) - 1;
										Edx = 0;
										for Idx = A, Top do
											local FlatIdent_2F289 = 0;
											while true do
												if (0 == FlatIdent_2F289) then
													Edx = Edx + 1;
													Stk[Idx] = Results[Edx];
													break;
												end
											end
										end
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
										Top = (Limit + A) - 1;
										Edx = 0;
										for Idx = A, Top do
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
										end
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
										Top = (Limit + A) - 1;
										Edx = 0;
										for Idx = A, Top do
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
										end
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
										Top = (Limit + A) - 1;
										Edx = 0;
										for Idx = A, Top do
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
										end
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
									end
								elseif (Enum <= 136) then
									local A;
									Stk[Inst[2]] = {};
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
								elseif (Enum == 137) then
									if (Inst[2] == Stk[Inst[4]]) then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								else
									local FlatIdent_3A6B4 = 0;
									local A;
									while true do
										if (FlatIdent_3A6B4 == 1) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											FlatIdent_3A6B4 = 2;
										end
										if (FlatIdent_3A6B4 == 4) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											if Stk[Inst[2]] then
												VIP = VIP + 1;
											else
												VIP = Inst[3];
											end
											break;
										end
										if (FlatIdent_3A6B4 == 2) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_3A6B4 = 3;
										end
										if (FlatIdent_3A6B4 == 0) then
											A = nil;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											FlatIdent_3A6B4 = 1;
										end
										if (3 == FlatIdent_3A6B4) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											FlatIdent_3A6B4 = 4;
										end
									end
								end
							elseif (Enum <= 141) then
								if (Enum <= 139) then
									local FlatIdent_21FB8 = 0;
									local A;
									while true do
										if (FlatIdent_21FB8 == 0) then
											A = Inst[2];
											Stk[A] = Stk[A]();
											break;
										end
									end
								elseif (Enum == 140) then
									if (Stk[Inst[2]] == Stk[Inst[4]]) then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								else
									local A;
									A = Inst[2];
									Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									VIP = Inst[3];
								end
							elseif (Enum <= 142) then
								local B;
								local A;
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Stk[A + 1]);
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								if Stk[Inst[2]] then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							elseif (Enum > 143) then
								local B;
								local A;
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Stk[A + 1]);
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								for Idx = Inst[2], Inst[3] do
									Stk[Idx] = nil;
								end
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
							else
								Stk[Inst[2]] = Inst[3] * Stk[Inst[4]];
							end
						elseif (Enum <= 168) then
							if (Enum <= 156) then
								if (Enum <= 150) then
									if (Enum <= 147) then
										if (Enum <= 145) then
											local A = Inst[2];
											do
												return Unpack(Stk, A, Top);
											end
										elseif (Enum > 146) then
											local B;
											local A;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
										else
											Stk[Inst[2]] = Inst[3] ~= 0;
										end
									elseif (Enum <= 148) then
										local A;
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									elseif (Enum == 149) then
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
									else
										local A;
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
									end
								elseif (Enum <= 153) then
									if (Enum <= 151) then
										local A;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									elseif (Enum == 152) then
										Stk[Inst[2]] = Stk[Inst[3]] + Stk[Inst[4]];
									else
										local B;
										local A;
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										if Stk[Inst[2]] then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
									end
								elseif (Enum <= 154) then
									local FlatIdent_20FDE = 0;
									local A;
									while true do
										if (FlatIdent_20FDE == 0) then
											A = nil;
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_20FDE = 1;
										end
										if (FlatIdent_20FDE == 4) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											VIP = Inst[3];
											break;
										end
										if (FlatIdent_20FDE == 3) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A](Stk[A + 1]);
											FlatIdent_20FDE = 4;
										end
										if (FlatIdent_20FDE == 2) then
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											FlatIdent_20FDE = 3;
										end
										if (FlatIdent_20FDE == 1) then
											A = Inst[2];
											Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_20FDE = 2;
										end
									end
								elseif (Enum > 155) then
									local FlatIdent_42214 = 0;
									local B;
									local A;
									while true do
										if (FlatIdent_42214 == 1) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											FlatIdent_42214 = 2;
										end
										if (FlatIdent_42214 == 5) then
											Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_42214 = 6;
										end
										if (2 == FlatIdent_42214) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_42214 = 3;
										end
										if (FlatIdent_42214 == 6) then
											VIP = Inst[3];
											break;
										end
										if (3 == FlatIdent_42214) then
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											FlatIdent_42214 = 4;
										end
										if (FlatIdent_42214 == 0) then
											B = nil;
											A = nil;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_42214 = 1;
										end
										if (FlatIdent_42214 == 4) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_42214 = 5;
										end
									end
								else
									local FlatIdent_807DC = 0;
									local A;
									local Results;
									local Limit;
									local Edx;
									while true do
										if (FlatIdent_807DC == 2) then
											for Idx = A, Top do
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
											end
											break;
										end
										if (FlatIdent_807DC == 0) then
											A = Inst[2];
											Results, Limit = _R(Stk[A]());
											FlatIdent_807DC = 1;
										end
										if (1 == FlatIdent_807DC) then
											Top = (Limit + A) - 1;
											Edx = 0;
											FlatIdent_807DC = 2;
										end
									end
								end
							elseif (Enum <= 162) then
								if (Enum <= 159) then
									if (Enum <= 157) then
										Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
									elseif (Enum == 158) then
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]] * Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]] + Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										do
											return Stk[Inst[2]];
										end
										VIP = VIP + 1;
										Inst = Instr[VIP];
										do
											return;
										end
									else
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
									end
								elseif (Enum <= 160) then
									local B;
									local A;
									A = Inst[2];
									Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3] ~= 0;
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
								elseif (Enum > 161) then
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									VIP = Inst[3];
								else
									local FlatIdent_5B76B = 0;
									local B;
									local A;
									while true do
										if (FlatIdent_5B76B == 7) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_5B76B = 8;
										end
										if (FlatIdent_5B76B == 1) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											FlatIdent_5B76B = 2;
										end
										if (0 == FlatIdent_5B76B) then
											B = nil;
											A = nil;
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_5B76B = 1;
										end
										if (FlatIdent_5B76B == 6) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_5B76B = 7;
										end
										if (8 == FlatIdent_5B76B) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_5B76B = 9;
										end
										if (FlatIdent_5B76B == 13) then
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											do
												return;
											end
											break;
										end
										if (FlatIdent_5B76B == 12) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											FlatIdent_5B76B = 13;
										end
										if (FlatIdent_5B76B == 4) then
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_5B76B = 5;
										end
										if (FlatIdent_5B76B == 2) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_5B76B = 3;
										end
										if (FlatIdent_5B76B == 11) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_5B76B = 12;
										end
										if (9 == FlatIdent_5B76B) then
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_5B76B = 10;
										end
										if (FlatIdent_5B76B == 5) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											FlatIdent_5B76B = 6;
										end
										if (FlatIdent_5B76B == 3) then
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_5B76B = 4;
										end
										if (FlatIdent_5B76B == 10) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											FlatIdent_5B76B = 11;
										end
									end
								end
							elseif (Enum <= 165) then
								if (Enum <= 163) then
									local B;
									local A;
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									for Idx = Inst[2], Inst[3] do
										Stk[Idx] = nil;
									end
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									for Idx = Inst[2], Inst[3] do
										Stk[Idx] = nil;
									end
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
								elseif (Enum == 164) then
									local B;
									local A;
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Unpack(Stk, A + 1, Inst[3]));
								else
									local FlatIdent_30DDB = 0;
									local B;
									local A;
									while true do
										if (FlatIdent_30DDB == 4) then
											Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											FlatIdent_30DDB = 5;
										end
										if (FlatIdent_30DDB == 7) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_30DDB = 8;
										end
										if (FlatIdent_30DDB == 6) then
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_30DDB = 7;
										end
										if (FlatIdent_30DDB == 5) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											FlatIdent_30DDB = 6;
										end
										if (FlatIdent_30DDB == 8) then
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											break;
										end
										if (FlatIdent_30DDB == 1) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											FlatIdent_30DDB = 2;
										end
										if (FlatIdent_30DDB == 2) then
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_30DDB = 3;
										end
										if (FlatIdent_30DDB == 3) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_30DDB = 4;
										end
										if (FlatIdent_30DDB == 0) then
											B = nil;
											A = nil;
											A = Inst[2];
											Stk[A](Unpack(Stk, A + 1, Inst[3]));
											FlatIdent_30DDB = 1;
										end
									end
								end
							elseif (Enum <= 166) then
								local A;
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								VIP = Inst[3];
							elseif (Enum > 167) then
								local B;
								local A;
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A](Stk[A + 1]);
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A](Stk[A + 1]);
								VIP = VIP + 1;
								Inst = Instr[VIP];
								VIP = Inst[3];
							else
								local FlatIdent_1FBA = 0;
								local T;
								local Edx;
								local Results;
								local Limit;
								local B;
								local A;
								while true do
									if (2 == FlatIdent_1FBA) then
										Stk[A] = Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_1FBA = 3;
									end
									if (5 == FlatIdent_1FBA) then
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										FlatIdent_1FBA = 6;
									end
									if (FlatIdent_1FBA == 7) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										FlatIdent_1FBA = 8;
									end
									if (FlatIdent_1FBA == 4) then
										A = Inst[2];
										Stk[A] = Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										FlatIdent_1FBA = 5;
									end
									if (FlatIdent_1FBA == 10) then
										for Idx = A, Top do
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
										end
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										T = Stk[A];
										for Idx = A + 1, Top do
											Insert(T, Stk[Idx]);
										end
										break;
									end
									if (FlatIdent_1FBA == 9) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
										Top = (Limit + A) - 1;
										Edx = 0;
										FlatIdent_1FBA = 10;
									end
									if (1 == FlatIdent_1FBA) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										FlatIdent_1FBA = 2;
									end
									if (FlatIdent_1FBA == 6) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										FlatIdent_1FBA = 7;
									end
									if (FlatIdent_1FBA == 8) then
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										FlatIdent_1FBA = 9;
									end
									if (FlatIdent_1FBA == 3) then
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_1FBA = 4;
									end
									if (FlatIdent_1FBA == 0) then
										T = nil;
										Edx = nil;
										Results, Limit = nil;
										B = nil;
										A = nil;
										Stk[Inst[2]] = Env[Inst[3]];
										FlatIdent_1FBA = 1;
									end
								end
							end
						elseif (Enum <= 180) then
							if (Enum <= 174) then
								if (Enum <= 171) then
									if (Enum <= 169) then
										local FlatIdent_3F68 = 0;
										local A;
										while true do
											if (FlatIdent_3F68 == 4) then
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_3F68 = 5;
											end
											if (5 == FlatIdent_3F68) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												FlatIdent_3F68 = 6;
											end
											if (3 == FlatIdent_3F68) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_3F68 = 4;
											end
											if (8 == FlatIdent_3F68) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												VIP = Inst[3];
												break;
											end
											if (FlatIdent_3F68 == 7) then
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												FlatIdent_3F68 = 8;
											end
											if (FlatIdent_3F68 == 1) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_3F68 = 2;
											end
											if (FlatIdent_3F68 == 2) then
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												FlatIdent_3F68 = 3;
											end
											if (FlatIdent_3F68 == 6) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_3F68 = 7;
											end
											if (FlatIdent_3F68 == 0) then
												A = nil;
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												FlatIdent_3F68 = 1;
											end
										end
									elseif (Enum > 170) then
										local FlatIdent_80B55 = 0;
										local B;
										local A;
										while true do
											if (FlatIdent_80B55 == 4) then
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												FlatIdent_80B55 = 5;
											end
											if (FlatIdent_80B55 == 2) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = {};
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												FlatIdent_80B55 = 3;
											end
											if (FlatIdent_80B55 == 0) then
												B = nil;
												A = nil;
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												FlatIdent_80B55 = 1;
											end
											if (FlatIdent_80B55 == 6) then
												Stk[A] = B[Inst[4]];
												break;
											end
											if (5 == FlatIdent_80B55) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												FlatIdent_80B55 = 6;
											end
											if (FlatIdent_80B55 == 3) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_80B55 = 4;
											end
											if (FlatIdent_80B55 == 1) then
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_80B55 = 2;
											end
										end
									else
										local FlatIdent_3B5FD = 0;
										local B;
										local A;
										while true do
											if (FlatIdent_3B5FD == 1) then
												Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_3B5FD = 2;
											end
											if (FlatIdent_3B5FD == 2) then
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												FlatIdent_3B5FD = 3;
											end
											if (FlatIdent_3B5FD == 0) then
												B = nil;
												A = nil;
												A = Inst[2];
												FlatIdent_3B5FD = 1;
											end
											if (3 == FlatIdent_3B5FD) then
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_3B5FD = 4;
											end
											if (FlatIdent_3B5FD == 4) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_3B5FD = 5;
											end
											if (FlatIdent_3B5FD == 6) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												break;
											end
											if (FlatIdent_3B5FD == 5) then
												A = Inst[2];
												Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												FlatIdent_3B5FD = 6;
											end
										end
									end
								elseif (Enum <= 172) then
									local A = Inst[2];
									local C = Inst[4];
									local CB = A + 2;
									local Result = {Stk[A](Stk[A + 1], Stk[CB])};
									for Idx = 1, C do
										Stk[CB + Idx] = Result[Idx];
									end
									local R = Result[1];
									if R then
										Stk[CB] = R;
										VIP = Inst[3];
									else
										VIP = VIP + 1;
									end
								elseif (Enum == 173) then
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									if not Stk[Inst[2]] then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								else
									local FlatIdent_C13B = 0;
									local Results;
									local Edx;
									local Limit;
									local B;
									local A;
									while true do
										if (FlatIdent_C13B == 2) then
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_C13B = 3;
										end
										if (FlatIdent_C13B == 3) then
											Results, Limit = _R(Stk[A](Stk[A + 1]));
											Top = (Limit + A) - 1;
											Edx = 0;
											for Idx = A, Top do
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
											end
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_C13B = 4;
										end
										if (FlatIdent_C13B == 1) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_C13B = 2;
										end
										if (0 == FlatIdent_C13B) then
											Results = nil;
											Edx = nil;
											Results, Limit = nil;
											B = nil;
											A = nil;
											Stk[Inst[2]] = Env[Inst[3]];
											FlatIdent_C13B = 1;
										end
										if (FlatIdent_C13B == 4) then
											A = Inst[2];
											Results = {Stk[A](Unpack(Stk, A + 1, Top))};
											Edx = 0;
											for Idx = A, Inst[4] do
												local FlatIdent_2444E = 0;
												while true do
													if (FlatIdent_2444E == 0) then
														Edx = Edx + 1;
														Stk[Idx] = Results[Edx];
														break;
													end
												end
											end
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_C13B = 5;
										end
										if (FlatIdent_C13B == 5) then
											VIP = Inst[3];
											break;
										end
									end
								end
							elseif (Enum <= 177) then
								if (Enum <= 175) then
									do
										return;
									end
								elseif (Enum > 176) then
									local DIP;
									local NStk;
									local Upv;
									local List;
									local Cls;
									local A;
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]]();
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Cls = {};
									for Idx = 1, #Lupvals do
										local FlatIdent_82AEE = 0;
										while true do
											if (0 == FlatIdent_82AEE) then
												List = Lupvals[Idx];
												for Idz = 0, #List do
													Upv = List[Idz];
													NStk = Upv[1];
													DIP = Upv[2];
													if ((NStk == Stk) and (DIP >= A)) then
														local FlatIdent_52DF2 = 0;
														while true do
															if (FlatIdent_52DF2 == 0) then
																Cls[DIP] = NStk[DIP];
																Upv[1] = Cls;
																break;
															end
														end
													end
												end
												break;
											end
										end
									end
									VIP = VIP + 1;
									Inst = Instr[VIP];
									do
										return;
									end
								else
									Stk[Inst[2]] = Wrap(Proto[Inst[3]], nil, Env);
								end
							elseif (Enum <= 178) then
								local Results;
								local Edx;
								local Results, Limit;
								local B;
								local A;
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Results, Limit = _R(Stk[A](Stk[A + 1]));
								Top = (Limit + A) - 1;
								Edx = 0;
								for Idx = A, Top do
									Edx = Edx + 1;
									Stk[Idx] = Results[Edx];
								end
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Results = {Stk[A](Unpack(Stk, A + 1, Top))};
								Edx = 0;
								for Idx = A, Inst[4] do
									Edx = Edx + 1;
									Stk[Idx] = Results[Edx];
								end
								VIP = VIP + 1;
								Inst = Instr[VIP];
								VIP = Inst[3];
							elseif (Enum == 179) then
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							else
								local FlatIdent_6E54 = 0;
								local A;
								while true do
									if (0 == FlatIdent_6E54) then
										A = Inst[2];
										Stk[A] = Stk[A](Stk[A + 1]);
										break;
									end
								end
							end
						elseif (Enum <= 186) then
							if (Enum <= 183) then
								if (Enum <= 181) then
									local FlatIdent_2F54B = 0;
									local A;
									while true do
										if (FlatIdent_2F54B == 9) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											FlatIdent_2F54B = 10;
										end
										if (FlatIdent_2F54B == 2) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_2F54B = 3;
										end
										if (FlatIdent_2F54B == 6) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											FlatIdent_2F54B = 7;
										end
										if (FlatIdent_2F54B == 12) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											VIP = Inst[3];
											break;
										end
										if (FlatIdent_2F54B == 1) then
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_2F54B = 2;
										end
										if (FlatIdent_2F54B == 0) then
											A = nil;
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_2F54B = 1;
										end
										if (8 == FlatIdent_2F54B) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_2F54B = 9;
										end
										if (FlatIdent_2F54B == 4) then
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_2F54B = 5;
										end
										if (FlatIdent_2F54B == 7) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_2F54B = 8;
										end
										if (FlatIdent_2F54B == 5) then
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											FlatIdent_2F54B = 6;
										end
										if (FlatIdent_2F54B == 10) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											FlatIdent_2F54B = 11;
										end
										if (FlatIdent_2F54B == 3) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_2F54B = 4;
										end
										if (FlatIdent_2F54B == 11) then
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_2F54B = 12;
										end
									end
								elseif (Enum > 182) then
									local A;
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									VIP = Inst[3];
								else
									Stk[Inst[2]] = {};
								end
							elseif (Enum <= 184) then
								local B;
								local A;
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
							elseif (Enum > 185) then
								if Stk[Inst[2]] then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							else
								local FlatIdent_96497 = 0;
								local A;
								while true do
									if (FlatIdent_96497 == 8) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										FlatIdent_96497 = 9;
									end
									if (FlatIdent_96497 == 4) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										FlatIdent_96497 = 5;
									end
									if (3 == FlatIdent_96497) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										FlatIdent_96497 = 4;
									end
									if (FlatIdent_96497 == 2) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										FlatIdent_96497 = 3;
									end
									if (FlatIdent_96497 == 1) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
										VIP = VIP + 1;
										FlatIdent_96497 = 2;
									end
									if (FlatIdent_96497 == 0) then
										A = nil;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										FlatIdent_96497 = 1;
									end
									if (FlatIdent_96497 == 6) then
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Stk[A + 1]);
										FlatIdent_96497 = 7;
									end
									if (FlatIdent_96497 == 7) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]] * Stk[Inst[4]];
										FlatIdent_96497 = 8;
									end
									if (FlatIdent_96497 == 5) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										FlatIdent_96497 = 6;
									end
									if (FlatIdent_96497 == 9) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										VIP = Inst[3];
										break;
									end
								end
							end
						elseif (Enum <= 189) then
							if (Enum <= 187) then
								if not Stk[Inst[2]] then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							elseif (Enum > 188) then
								local A = Inst[2];
								Top = (A + Varargsz) - 1;
								for Idx = A, Top do
									local FlatIdent_161B8 = 0;
									local VA;
									while true do
										if (FlatIdent_161B8 == 0) then
											VA = Vararg[Idx - A];
											Stk[Idx] = VA;
											break;
										end
									end
								end
							else
								local A;
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							end
						elseif (Enum <= 191) then
							if (Enum == 190) then
								local A;
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Upvalues[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								if Stk[Inst[2]] then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							else
								local A;
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								if (Inst[2] < Stk[Inst[4]]) then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							end
						elseif (Enum == 192) then
							local A;
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A]();
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
						else
							do
								return Stk[Inst[2]]();
							end
						end
						VIP = VIP + 1;
						break;
					end
					if (FlatIdent_1076E == 0) then
						Inst = Instr[VIP];
						Enum = Inst[1];
						FlatIdent_1076E = 1;
					end
				end
			end
		end;
	end
	return Wrap(Deserialize(), {}, vmenv)(...);
end
return VMCall("LOL!F43O00030A3O006C6F6164737472696E6703043O0067616D6503073O00482O747047657403493O00682O7470733A2O2F6769746875622E636F6D2F64617769642D736372697074732F466C75656E742F72656C65617365732F6C61746573742F646F776E6C6F61642F6D61696E2E6C756103543O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F64617769642D736372697074732F466C75656E742F6D61737465722F412O646F6E732F536176654D616E616765722E6C756103593O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F64617769642D736372697074732F466C75656E742F6D61737465722F412O646F6E732F496E746572666163654D616E616765722E6C7561030C3O0043726561746557696E646F7703053O005469746C65030E3O005820485542205052454D49554D2003083O005375625469746C6503093O00627920446561636F6E03083O005461625769647468026O00644003043O0053697A6503053O005544696D32030A3O0066726F6D4F2O66736574025O00208240025O00C07C4003073O00416372796C6963010003053O005468656D6503063O004461726B6572030B3O004D696E696D697A654B657903043O00456E756D03073O004B6579436F6465030C3O005269676874436F6E74726F6C03083O004361746368696E6703063O00412O6454616203043O0049636F6E034O0003063O00506C6179657203073O005068797369637303073O0056697375616C73030A3O004175746F6D617469637303043O004D69736303073O00436F6E6669677303083O0053652O74696E677303073O004F7074696F6E73030A3O004765745365727669636503073O00506C6179657273030A3O0052756E53657276696365030B3O004C6F63616C506C6179657203083O004765744D6F757365026O000840026O005E40028O00030B3O0042752O746F6E31446F776E03073O00436F2O6E65637403073O005374652O706564026O00F03F03083O004D79546F2O676C6503083O0053657456616C756503093O00412O64536C69646572030D3O004D61676E657473416D6F756E74030E3O004D61676E65747320416D6F756E74030B3O004465736372697074696F6E031E3O0053657420746865206D61676E65742072656163682064697374616E63652E03073O0044656661756C742O033O004D696E2O033O004D617803083O00526F756E64696E6703083O0043612O6C6261636B027O0040026O001040030A3O00436174636844656C6179030B3O0043617463682044656C6179032B3O00536574207468652064656C6179206265666F72652061637469766174696E6720746865206D61676E65742E03093O004F6E4368616E67656403093O00412O64546F2O676C65030E3O00456E61626C65204D61676E65747303023O005F47030A3O0050752O6C566563746F7203123O0050752O6C566563746F7244697374616E6365026O002E40030F3O0050752O6C566563746F72466F726365026O00494003093O00436861726163746572030C3O0057616974466F724368696C6403083O0048756D616E6F696403103O0048756D616E6F6964522O6F7450617274030C3O00412O6450617261677261706803253O0050752O6C20566563746F722070752O6C7320796F7520746F77616473207468652062612O6C03103O0050752O6C566563746F72546F2O676C65030B3O0050752O6C20566563746F72030B3O0050562044697374616E636503143O0050752O6C20566563746F722044697374616E636503183O0044697374616E636520666F722050752O6C20566563746F7203083O00505620466F72636503113O0050752O6C20566563746F7220466F72636503153O00466F72636520666F722050752O6C20566563746F72026O002440026O00694003103O0055736572496E70757453657276696365030A3O00496E707574426567616E030C3O006F6E496E707574426567616E030F3O0057616C6B53702O6564546F2O676C6503173O00456E61626C652057616C6B53702O656420536C69646572030F3O0057616C6B53702O6564536C6964657203093O0057616C6B53702O656403103O0041646A7573742057616C6B53702O6564026O003040026O003E40026O001440030F3O004A756D70506F776572546F2O676C6503173O00456E61626C65204A756D70506F77657220536C69646572030F3O004A756D70506F776572536C6964657203093O004A756D70506F77657203103O0041646A757374204A756D70506F776572025O0080514003083O004175746F52757368030E3O004175746F52757368546F2O676C6503093O005275736844656C6179030A3O00527573682044656C617903103O0044656C617920696E207365636F6E6473026O00E03F03073O005365676D656E7403083O00496E7374616E63652O033O006E657703043O005061727403083O00416E63686F7265642O01030C3O005472616E73706172656E6379026O33D33F03053O00436F6C6F7203063O00436F6C6F723303073O0066726F6D524742025O00E06F4003083O004D6174657269616C03043O004E656F6E030A3O0043616E436F2O6C69646503073O00566563746F7233029A5O99C93F03043O004E616D65030B3O004265616D5365676D656E7403063O00506172616D73030D3O0052617963617374506172616D73030B3O0049676E6F72655761746572030A3O0046696C7465725479706503113O005261796361737446696C7465725479706503093O0057686974656C69737403083O004361737453746570029A5O99A93F030E3O004C6173745361766564506F776572026O004E40030F3O005365676D656E744C69666574696D65026O002040030E3O00476574436F2O6C696461626C6573030B3O00576970654D61726B657273030A3O004765744C616E64696E67030F3O00537461727456697375616C697A6572030E3O0053746F7056697375616C697A657203093O00776F726B7370616365030A3O004368696C64412O646564030F3O00477261706865725F456E61626C656403123O005472616A6563746F72792047726170686572030E3O00412O64436F6C6F727069636B657203153O005472616A6563746F7279436F6C6F727069636B657203103O005472616A6563746F727920436F6C6F7203343O004368616E67652074686520636F6C6F7220616E64207472616E73706172656E6379206F6620746865207472616A6563746F72792E025O00804240025O00C06240025O00C0674003083O00416E74692D4C616703093O00416E746941646D696E030A3O00416E74692D41646D696E030D3O0052656E6465725374652O70656403093O005363722O656E47756903063O00506172656E7403093O00506C6179657247756903093O00546578744C6162656C03083O00506F736974696F6E026O0059C003103O004261636B67726F756E64436F6C6F723303163O004261636B67726F756E645472616E73706172656E6379030A3O0054657874436F6C6F723303083O005465787453697A65026O00384003163O00546578745374726F6B655472616E73706172656E637903103O00546578745374726F6B65436F6C6F7233030B3O00546578745772612O706564030E3O005465787458416C69676E6D656E7403063O0043656E746572030E3O005465787459416C69676E6D656E7403073O0056697369626C6503083O005549436F726E6572030C3O00436F726E657252616469757303043O005544696D026O00284003083O0055495374726F6B65030F3O00412O706C795374726F6B654D6F646503063O00426F7264657203093O00546869636B6E652O7303103O00496E6469636174696F6E546F2O676C65030A3O00496E6469636174696F6E030A3O005365744C69627261727903103O0053657449676E6F7265496E646578657303093O00536574466F6C646572030D3O00584875622O463253637269707403113O00584875622O46325363726970742F2O463203153O004275696C64496E7465726661636553656374696F6E03123O004275696C64436F6E66696753656374696F6E03093O0053656C65637454616203123O004C6F61644175746F6C6F6164436F6E66696703053O007072696E7403183O00427970612O7320627920616D696E672E5F2E204F662O632E03173O00496E697469616C697A696E6720414320427970612O732103083O00636C6F6E6572656603113O005265706C69636174656453746F7261676503053O005465616D73030C3O0054772O656E5365727669636503053O00537461747303073O00506C6163654964022O00101CF891FE41022O004034CD90FE4103043O007461736B03053O00737061776E03153O005265706C6963617465642068616E647368616B652E030E3O00436861726163746572412O64656403043O005761697403043O006D61746803063O0072616E646F6D025O00408F40025O006AF84003053O00436C6F636B030C3O00682O6F6B66756E6374696F6E03023O006F7303043O006461746503083O004E616D6563612O6C030E3O00682O6F6B6D6574616D6574686F64030A3O002O5F6E616D6563612O6C03043O007761697403073O0052656D6F74657303133O00436861726163746572536F756E644576656E74031A3O00466F756E642068616E647368616B6520617267756D656E74732E03053O00706169727303053O00676574676303043O007479706503083O0066756E6374696F6E03073O00676574696E666F03063O00736F7572636503043O0066696E6403183O00506C617965724D6F64756C652E4C6F63616C536372697074031F3O00482O6F6B656420612O6C20616E746963686561742066756E6374696F6E732E03113O00446F6E6521204E6F77204C6F6164696E6700E2032O0012373O00013O00122O000100023O00202O00010001000300122O000300046O000100039O0000026O0001000200122O000100013O00122O000200023O00202O00020002000300122O000400056O000200046O00013O00024O00010001000200122O000200013O00122O000300023O00202O00030003000300122O000500066O000300056O00023O00024O00020001000200202O00033O00074O00053O000700302O00050008000900302O0005000A000B00302O0005000C000D00122O0006000F3O00202O00060006001000122O000700113O00122O000800126O00060008000200102O0005000E000600302O00050013001400302O00050015001600122O000600183O00202O00060006001900202O00060006001A00102O0005001700064O0003000500024O00043O000700202O00050003001C4O00073O000200302O00070008001B00302O0007001D001E4O00050007000200102O0004001B000500202O00050003001C4O00073O000200302O00070008001F00302O0007001D001E4O00050007000200102O0004001F000500202O00050003001C4O00073O000200302O00070008002000302O0007001D001E4O00050007000200102O00040020000500202O00050003001C4O00073O000200302O00070008002100302O0007001D001E4O00050007000200102O00040021000500202O00050003001C4O00073O000200302O00070008002200302O0007001D001E4O00050007000200102O00040022000500202O00050003001C4O00073O000200302O00070008002300302O0007001D001E4O00050007000200102O00040023000500202O00050003001C4O00073O000200302O00070008002500302O0007001D001E2O006400050007000200102O00040024000500202O00053O002600122O000600023O00202O00060006002700122O000800286O00060008000200122O000700023O00203400070007002700122O000900296O00070009000200202O00080006002A00202O00090008002B2O002900090002000200122O000A002C6O000B8O000C5O00122O000D002D3O00122O000E002D3O00122O000F002E3O0002B000105O0002B0001100013O00065100120002000100012O006A3O000A3O00065100130003000100012O006A3O000D3O00065100140004000100032O006A3O000E4O006A3O000C4O006A3O000B3O00065100150005000100032O006A3O00084O006A3O000C4O006A3O000B3O0020B300160009002F002008001600160030000651001800060001000A2O006A3O000C4O006A3O00084O006A3O000B4O006A3O00134O006A3O00124O006A3O000A4O006A3O000F4O006A3O00114O006A3O000E4O006A3O00104O00790016001800010020B300160007003100200800160016003000065100180007000100072O006A3O000B4O006A3O00084O006A3O00134O006A3O000E4O006A3O00104O006A3O000F4O006A3O00114O00790016001800010012240016002E4O006C001700193O00260F001600A4000100320004213O00A400010020B3001A00050033002058001A001A00344O001C8O001A001C000100202O001A0004001B00202O001A001A003500122O001C00366O001D3O000700302O001D0008003700302O001D0038003900302O001D003A002E003074001D003B002E003074001D003C002D003074001D003D0032000651001E0008000100022O006A3O000C4O006A3O000E3O001063001D003E001E2O0054001A001D00022O006A0018001A3O0012240016003F3O00260F001600AA000100400004213O00AA0001002008001A00190034001224001C002E4O0079001A001C00010004213O00ED0001000E89002C00C8000100160004213O00C80001001224001A002E3O00260F001A00B1000100320004213O00B10001001224001600403O0004213O00C8000100260F001A00AD0001002E0004213O00AD00010020B3001B0004001B00201C001B001B003500122O001D00416O001E3O000700302O001E0008004200302O001E0038004300302O001E003A002E00302O001E003B002E00302O001E003C003200302O001E003D0032000651001F0009000100012O006A3O000F3O001063001E003E001F2O0054001B001E00022O006A0019001B3O002008001B00190044000651001D000A000100012O006A3O000F4O0079001B001D0001001224001A00323O0004213O00AD000100260F001600D30001003F0004213O00D30001002008001A00180044000651001C000B000100022O006A3O000C4O006A3O000E4O00AA001A001C000100202O001A0018003400122O001C002E6O001A001C000100122O0016002C3O00260F0016008D0001002E0004213O008D0001001224001A002E3O00260F001A00DA000100320004213O00DA0001001224001600323O0004213O008D000100260F001A00D60001002E0004213O00D600010020B3001B0004001B002039001B001B004500122O001D00336O001E3O000200302O001E0008004600302O001E003A00144O001B001E00024O0017001B3O00202O001B00170044000651001D000C000100032O006A3O00054O006A3O00144O006A3O00154O0079001B001D0001001224001A00323O0004213O00D600010004213O008D0001001228001600473O00304200160048001400122O001600473O00302O00160049004A00122O001600473O00302O0016004B004C00122O001600023O00202O00160016002700122O001800286O00160018000200202O00160016002A0020B300160016004D00203D00170016004E00122O0019004F6O00170019000200202O00180016004E00122O001A00506O0018001A00024O00195O000651001A000D000100022O006A3O00194O006A3O00173O002093001B0004001B00202O001B001B00514O001D3O000100302O001D000800524O001B001D000100202O001B0004001B00202O001B001B004500122O001D00536O001E3O000200302O001E00080054003074001E003A00142O0054001B001E0002002008001C001B0044000651001E000E000100022O006A3O00054O006A3O001A4O0048001C001E000100202O001C0005005300202O001C001C00344O001E8O001C001E000100202O001C0004001B00202O001C001C003500122O001E00556O001F3O000700302O001F00080056003074001F00380057003074001F003A004A003074001F003B0032003074001F003C004C003074001F003D00320002B00020000F3O001063001F003E00202O0054001C001F0002002008001D001C00440002B0001F00106O001D001F000100202O001D001C003400122O001F004A6O001D001F000100202O001D0004001B00202O001D001D003500122O001F00586O00203O000700302O00200008005900302O00200038005A0030740020003A004C0030740020003B005B0030740020003C005C0030740020003D00320002B0002100113O0010630020003E00212O0054001D00200002002008001E001D00440002B0002000124O00A5001E0020000100202O001E001D003400122O0020004C6O001E0020000100122O001E00023O00202O001E001E002700122O0020005D6O001E00200002000651001F0013000100012O006A3O00083O0020670020001E005E00202O00200020003000122O0022005F6O00200022000100202O00200004001F00202O00200020004500122O002200606O00233O000200302O00230008006100302O0023003A00142O005400200023000200205900210004001F00202O00210021003500122O002300626O00243O000700302O00240008006300302O00240038006400302O0024003A006500302O0024003B003200302O0024003C006600302O0024003D006700065100250014000100012O006A3O00053O0010630024003E00252O005400210024000200200800220021004400065100240015000100012O006A3O00056O00220024000100202O00220021003400122O002400656O00220024000100202O00220004001F00202O00220022004500122O002400686O00253O000200302O00250008006900302O0025003A00142O005400220025000200205900230004001F00202O00230023003500122O0025006A6O00263O000700302O00260008006B00302O00260038006C00302O0026003A004C00302O0026003B005B00302O0026003C006D00302O0026003D006700065100270016000100012O006A3O00053O0010630026003E00272O005400230026000200200800240023004400065100260017000100012O006A3O00054O007800240026000100202O00240023003400122O0026004C6O00240026000100122O002400473O00302O0024006E001400065100240018000100012O006A3O00063O0002B0002500193O0006510026001A000100032O006A3O00244O006A3O00254O006A3O00083O0012240027002E4O006C0028002A3O00260F002700CC2O0100320004213O00CC2O012O006C002A002A3O00260F0028009A2O0100320004213O009A2O01002008002B00290044000651002D001B000100022O006A3O00054O006A3O00264O00A0002B002D000100202O002B0005006F00202O002B002B00344O002D8O002B002D000100122O0028003F3O00260F002800AE2O01002E0004213O00AE2O01001224002B002E3O00260F002B00A12O0100320004213O00A12O01001224002800323O0004213O00AE2O0100260F002B009D2O01002E0004213O009D2O010020B3002C00040020002069002C002C004500122O002E006F6O002F3O000200302O002F0008006E00302O002F003A00144O002C002F00024O0029002C3O00102O0005006F002900122O002B00323O00044O009D2O0100260F002800C12O01003F0004213O00C12O010020B3002B0004002000201C002B002B003500122O002D00706O002E3O000700302O002E0008007100302O002E0038007200302O002E003A007300302O002E003B002E00302O002E003C003200302O002E003D0067000651002F001C000100012O006A3O00263O001096002E003E002F4O002B002E00024O002A002B3O00102O00050070002A00122O0028002C3O00260F0028008E2O01002C0004213O008E2O01002008002B002A00440002B0002D001D4O0057002B002D000100202O002B002A003400122O002D00736O002B002D000100044O00D22O010004213O008E2O010004213O00D22O0100260F0027008B2O01002E0004213O008B2O010012240028002E4O006C002900293O001224002700323O0004213O008B2O012O009200276O006C002800283O0002B00029001E3O0002B0002A001F4O0088002B5O00122O002C00753O00202O002C002C007600122O002D00776O002C0002000200102O002B0074002C00202O002C002B007400302O002C0078007900202O002C002B007400302O002C007A007B0020B3002C002B0074001294002D007D3O00202O002D002D007E00122O002E007F3O00122O002F002E3O00122O0030002E6O002D0030000200102O002C007C002D00202O002C002B007400122O002D00183O00202O002D002D00800020B3002D002D00810010BC002C0080002D00202O002C002B007400302O002C0082001400202O002C002B007400122O002D00833O00202O002D002D007600122O002E00843O00122O002F00843O00122O003000846O002D00300002001063002C000E002D0020C0002C002B007400302O002C0085008600122O002C00883O00202O002C002C00764O002C0001000200102O002B0087002C00202O002C002B008700302O002C0089007900202O002C002B008700122O002D00183O0020B3002D002D008B002095002D002D008C00102O002C008A002D00302O002B008D008E00302O002B008F009000302O002B009100920002B0002C00203O001063002B0093002C0002B0002C00213O001063002B0094002C000651002C0022000100012O006A3O002B3O001063002B0095002C000651002C0023000100012O006A3O002B3O001063002B0096002C000651002C0024000100012O006A3O002B3O001063002B0097002C001228002C00983O0020B3002C002C0099002008002C002C0030000651002E0025000100012O006A3O002B4O0086002C002E000100202O002C0004002100202O002C002C004500122O002E009A6O002F3O000200302O002F0008009B00302O002F003A00144O002C002F000200202O002D002C0044000651002F0026000100022O006A3O002C4O006A3O002B4O002F002D002F000100202O002D0004002100202O002D002D009C00122O002F009D6O00303O000400302O00300008009E00302O00300038009F00302O0030007A002E00122O0031007D3O00202O00310031007E001224003200A03O002O12003300A13O00122O003400A26O00310034000200102O0030003A00314O002D0030000200202O002E002D004400065100300027000100022O006A3O002D4O006A3O002B4O007B002E0030000100202O002E0004002100202O002E002E004500122O003000A36O00313O000200302O0031000800A300302O0031003A00144O002E003100024O002F8O00305O00065100310028000100012O006A3O00303O00065100320029000100012O006A3O00303O0002B00033002A3O0020080034002E00440006510036002B000100052O006A3O002E4O006A3O002F4O006A3O00314O006A3O00334O006A3O00324O00790034003600010012240034002E4O006C003500353O00260F00340059020100320004213O005902010020B30036000500A40020080036003600342O0092003800014O00790036003800010004213O0071020100260F003400520201002E0004213O005202010012240036002E3O00260F00360060020100320004213O00600201001224003400323O0004213O0052020100260F0036005C0201002E0004213O005C02010020B300370004002300203900370037004500122O003900A46O003A3O000200302O003A000800A500302O003A003A00794O0037003A00024O003500373O00202O0037003500440006510039002C000100012O006A3O00054O0079003700390001001224003600323O0004213O005C02010004213O00520201001228003400023O00203400340034002700122O003600296O00340036000200202O0034003400A600202O0034003400300002B00036002D4O006500340036000100122O003400023O00202O00340034002700122O003600286O00340036000200202O00350034002A00122O003600023O00202O00360036002700122O003800296O00360038000200202O00370035002B4O00370002000200122O003800753O00202O00380038007600122O003900A76O00380002000200202O0039003500A900102O003800A8003900122O003900753O00202O00390039007600122O003A00AA6O00390002000200102O003900A8003800122O003A000F3O00202O003A003A007600122O003B002E3O00122O003C005C3O00122O003D002E3O00122O003E004C6O003A003E000200102O0039000E003A00122O003A000F3O00202O003A003A007600122O003B00733O00122O003C00AC3O00122O003D002E3O00122O003E00906O003A003E000200102O003900AB003A00122O003A007D3O00202O003A003A007E00122O003B004C3O00122O003C004C3O00122O003D004C6O003A003D000200102O003900AD003A00302O003900AE007B00122O003A007D3O00202O003A003A007E00122O003B007F3O00122O003C007F3O00122O003D007F6O003A003D000200102O003900AF003A00302O003900B000B100302O003900B2007B00122O003A007D3O00202O003A003A007E00122O003B007F3O00122O003C007F3O00122O003D007F6O003A003D000200102O003900B3003A00302O003900B4007900122O003A00183O00202O003A003A00B500202O003A003A00B600102O003900B5003A00122O003A00183O00202O003A003A00B700202O003A003A00B600102O003900B7003A00302O003900B8001400122O003A00753O00202O003A003A007600122O003B00B96O003A0002000200122O003B00BB3O00202O003B003B007600122O003C002E3O001231003D00BC6O003B003D000200102O003A00BA003B00102O003A00A8003900122O003B00753O00202O003B003B007600122O003C00BD6O003B0002000200122O003C00183O00202O003C003C00BE0020B3003C003C00BF001041003B00BE003C00122O003C007D3O00202O003C003C007E00122O003D007F3O00122O003E007F3O00122O003F007F6O003C003F000200102O003B007C003C00302O003B00C0003F00102O003B00A80039000651003C002E000100012O006A3O00393O0020B3003D0037002F002008003D003D0030000651003F002F000100082O006A3O000C4O006A3O00354O006A3O00134O006A3O00124O006A3O000A4O006A3O00104O006A3O00114O006A3O000B4O0079003D003F00010020B3003D00360031002008003D003D0030000651003F0030000100042O006A3O00394O006A3O00354O006A3O00134O006A3O003C4O0086003D003F000100202O003D0004002100202O003D003D004500122O003F00C16O00403O000200302O0040000800C200302O0040003A00144O003D0040000200202O003E003D004400065100400031000100022O006A3O00054O006A3O00394O0087003E0040000100202O003E000500C100202O003E003E00344O00408O003E0040000100202O003E3O002600202O003F000100C34O00418O003F0041000100202O003F000200C34O00418O003F0041000100202O003F000100C44O00418O003F0041000100202O003F000200C500122O004100C66O003F0041000100202O003F000100C500122O004100C76O003F0041000100202O003F000200C800202O0041000400244O003F0041000100202O003F000100C900202O0041000400244O003F0041000100202O003F000300CA00122O004100326O003F0041000100202O003F000100CB4O003F0002000100122O003F00CC3O00122O004000CD6O003F0002000100122O003F00CC3O00122O004000CE6O003F0002000100122O003F00CF3O00122O004000023O00202O00400040002700122O004200286O004000426O003F3O000200122O004000CF3O00122O004100023O00202O00410041002700122O004300D06O004100436O00403O000200122O004100CF3O00122O004200023O00202O00420042002700122O004400296O004200446O00413O000200122O004200CF3O00122O004300023O00202O00430043002700122O0045005D6O004300456O00423O000200122O004300CF3O00122O004400023O00202O00440044002700122O004600D16O004400466O00433O000200122O004400CF3O00122O004500023O00202O00450045002700122O004700D26O004500476O00443O000200122O004500CF3O00122O004600023O00202O00460046002700122O004800D36O004600486O00453O0002001281004600CF3O00122O004700023O00202O00470047002700122O004900296O004700496O00463O000200122O004700023O00202O0047004700D400262O0047005C030100D50004213O005C0301001228004700023O0020B30047004700D400260F004700DA030100D60004213O00DA03010012240047002E4O006C004800513O00260F0047006D030100400004213O006D030100065100510032000100032O006A3O004E4O006A3O004F4O006A3O004D3O001228005200D73O0020B30052005200D800065100530033000100012O006A3O00514O008D00520002000100122O005200CC3O00122O005300D96O00520002000100044O00D9030100260F004700840301002E0004213O00840301001228005200023O00204E00520052002700122O005400D06O0052005400024O004800523O00122O005200023O00202O00520052002700122O005400286O00520054000200202O00490052002A00202O00520049004D000684004A0080030100520004213O008003010020B30052004900DA0020080052005200DB2O00B40052000200022O006A004A00523O00064D004B00830301004A0004213O008303010020B3004B004A0050001224004700323O00260F004700A70301003F0004213O00A70301001228005200DC3O0020970052005200DD00122O005300DE3O00122O005400DF6O0052005400024O005000523O00122O005200E13O00122O005300E23O00202O0053005300E300065100540034000100022O006A3O004C4O006A3O00504O006D00520054000200102O004C00E0005200122O005200E53O00122O005300023O00122O005400E63O00065100550035000100042O006A3O004E4O006A3O004D4O006A3O004F4O006A3O004C4O0054005200550002001063004C00E400520006BB004F00A6030100010004213O00A603010006BB004D00A6030100010004213O00A60301001228005200D73O0020B30052005200E72O00400052000100010004213O009E03010012240047002C3O00260F004700B2030100320004213O00B203012O00B600526O00A3004C00526O004D004D3O00202O00520048004E00122O005400E86O00520054000200202O004E005200E94O004F004F3O00122O0047003F3O00260F0047005E0301002C0004213O005E0301001228005200CC3O001225005300EA6O00520002000100122O005200D73O00202O0052005200E700122O0053002C6O00520002000100122O005200EB3O00122O005300EC6O005300016O00523O00540004213O00D20301001228005700ED4O006A005800564O00B400570002000200260F005700D2030100EE0004213O00D20301001228005700EF4O008E005800566O00570002000200202O0057005700F000202O0057005700F100122O005900F26O00570059000200062O005700D203013O0004213O00D20301001228005700E14O006A005800563O0002B0005900364O00790057005900010006AC005200C0030100020004213O00C00301001228005200CC3O001224005300F34O002B005200020001001224004700403O0004213O005E03012O006600475O001228004700D73O0020B10047004700E74O00470001000100122O004700CC3O00122O004800F46O0047000200019O006O00013O00373O00083O00028O00026O00F03F03043O0053697A6503073O00566563746F72332O033O006E6577030E3O0046696E6446697273744368696C64030A3O004361746368526967687403093O0043617463684C65667402363O001224000200014O006C000300053O00260F00020007000100010004213O00070001001224000300014O006C000400043O001224000200023O00260F00020002000100020004213O000200012O006C000500053O00260F0003001F000100020004213O001F00010006BA0004003500013O0004213O003500010006BA0005003500013O0004213O00350001001228000600043O0020A90006000600054O000700016O000800016O000900016O00060009000200102O00040003000600122O000600043O00202O0006000600054O000700016O000800016O000900016O00060009000200102O00050003000600044O0035000100260F0003000A000100010004213O000A0001001224000600013O00260F0006002D000100010004213O002D000100200800073O000600126B000900076O0007000900024O000400073O00202O00073O000600122O000900086O0007000900024O000500073O00122O000600023O00260F00060022000100020004213O00220001001224000300023O0004213O000A00010004213O002200010004213O000A00010004213O003500010004213O000200012O00AF3O00017O00053O00028O00030E3O0046696E6446697273744368696C64030A3O004361746368526967687403093O0043617463684C656674026O00F03F02303O001224000200014O006C000300043O00260F00020015000100010004213O00150001001224000500013O000E8900010010000100050004213O0010000100200800063O000200126B000800036O0006000800024O000300063O00202O00063O000200122O000800046O0006000800024O000400063O00122O000500053O00260F00050005000100050004213O00050001001224000200053O0004213O001500010004213O0005000100260F00020002000100050004213O000200010006BA0003002F00013O0004213O002F00010006BA0004002F00013O0004213O002F0001001224000500014O006C000600063O00260F00050023000100010004213O002300012O006C000600063O00065100063O000100012O006A3O00013O001224000500053O00260F0005001D000100050004213O001D00012O006A000700064O009A000800046O0007000200014O000700066O000800036O00070002000100044O002F00010004213O001D00010004213O002F00010004213O000200012O00AF3O00013O00013O000B3O00028O00027O004003083O00506F736974696F6E03073O0044657374726F7903083O00496E7374616E63652O033O006E6577030E3O0057656C64436F6E73747261696E7403053O005061727430026O00F03F03053O00506172743103063O00506172656E74011B3O001224000100014O006C000200023O00260F0001000A000100020004213O000A00012O006100035O00209C00043O000300102O00030003000400202O0003000200044O00030002000100044O001A0001000E8900010013000100010004213O00130001001228000300053O00200A00030003000600122O000400076O0003000200024O000200033O00102O000200083O00122O000100093O00260F00010002000100090004213O000200012O006100035O0010630002000A00030010630002000B3O001224000100023O0004213O000200012O00AF3O00017O00063O00028O0003043O007469636B026O00F03F03043O007461736B03043O007761697403153O0046696E6446697273744368696C644F66436C612O7303323O001224000300014O006C000400043O00260F0003000B000100010004213O000B00010006BB00020007000100010004213O000700012O006100025O001228000500024O008B0005000100022O006A000400053O001224000300033O000E8900030002000100030004213O00020001001228000500024O008B0005000100022O009D0005000500040006520005002E000100020004213O002E0001001224000500014O006C000600063O000E890003001A000100050004213O001A0001001228000700043O0020B30007000700052O00400007000100010004213O000D000100260F00050014000100010004213O00140001001224000700013O00260F00070027000100010004213O0027000100200800083O00062O006A000A00014O00540008000A00022O006A000600083O0006BA0006002600013O0004213O002600012O005C000600023O001224000700033O00260F0007001D000100030004213O001D0001001224000500033O0004213O001400010004213O001D00010004213O001400010004213O000D00012O006C000500054O005C000500023O0004213O000200012O00AF3O00017O000A3O00028O00026O00F03F03053O00706169727303093O00776F726B7370616365030B3O004765744368696C6472656E03043O004E616D6503083O00462O6F7462612O6C03083O00506F736974696F6E03103O0048756D616E6F6964522O6F745061727403093O004D61676E6974756465012B3O001224000100014O006C000200033O00260F00010007000100010004213O000700012O006C000200024O006100035O001224000100023O00260F00010002000100020004213O00020001001228000400033O00122A000500043O00202O0005000500054O000500066O00043O000600044O002600010020B300090008000600260F00090026000100070004213O00260001001224000900014O006C000A000A3O00260F00090014000100010004213O001400010020B3000B00080008002033000C3O000900202O000C000C00084O000B000B000C00202O000A000B000A00062O000A0026000100030004213O00260001001224000B00013O00260F000B001E000100010004213O001E00012O006A0003000A4O006A000200083O0004213O002600010004213O001E00010004213O002600010004213O001400010006AC0004000F000100020004213O000F00012O005C000200023O0004213O000200012O00AF3O00017O00023O00028O00026O00F03F010E3O001224000100013O00260F00010005000100020004213O000500012O00197O0004213O000D000100260F00010001000100010004213O000100012O0092000200014O002D000200016O000200016O000200023O00122O000100023O00044O000100012O00AF3O00017O00093O00028O00026O00F03F03093O00436861726163746572030E3O0046696E6446697273744368696C64030A3O004361746368526967687403093O0043617463684C65667403043O0053697A6503073O00566563746F72332O033O006E657700313O0012243O00014O006C000100013O00260F3O0028000100020004213O002800012O006100025O0020B30001000200030006BA0001003000013O0004213O00300001002008000200010004001224000400054O00540002000400020006BA0002003000013O0004213O00300001002008000200010004001224000400064O00540002000400020006BA0002003000013O0004213O00300001001224000200013O00260F00020013000100010004213O001300010020B300030001000500124C000400083O00202O00040004000900122O000500023O00122O000600023O00122O000700026O00040007000200102O00030007000400202O00030001000600122O000400083O00202O00040004000900122O000500023O00122O000600023O00122O000700026O00040007000200102O00030007000400044O003000010004213O001300010004213O0030000100260F3O0002000100010004213O000200012O009200026O002D000200016O00028O000200023O00124O00023O00044O000200012O00AF3O00017O00063O0003093O00436861726163746572028O00026O00F03F03103O00546F7563685472616E736D692O74657203043O007461736B03043O0077616974003F4O00617O0006BB3O0004000100010004213O000400012O00AF3O00014O00613O00013O0020B35O00010006BA3O003E00013O0004213O003E0001001224000100024O006C000200023O00260F0001000F000100030004213O000F00012O009200036O0019000300023O0004213O003E0001000E890002000A000100010004213O000A00012O0061000300034O006A00046O00B40003000200022O006A000200033O0006BA0002003C00013O0004213O003C00012O0061000300044O001F000400023O00122O000500046O000600056O00030006000200062O0003003C00013O0004213O003C0001001224000300024O006C000400043O00260F0003002B000100030004213O002B0001001228000500053O0020B70005000500064O000600066O0005000200014O000500076O00068O000700026O00050007000100044O003C000100260F00030020000100020004213O00200001001224000500023O00260F00050032000100030004213O00320001001224000300033O0004213O0020000100260F0005002E000100020004213O002E00012O0061000400084O0083000600096O00078O000800046O00060008000100122O000500033O00044O002E00010004213O00200001001224000100033O0004213O000A00012O00AF3O00017O00043O0003093O00436861726163746572028O0003043O007461736B03043O007761697400224O00617O0006BB3O0004000100010004213O000400012O00AF3O00014O00613O00013O0020B35O00010006BA3O002100013O0004213O00210001001224000100024O006C000200023O00260F0001000A000100020004213O000A00012O0061000300024O006A00046O00B40003000200022O006A000200033O0006BA0002002100013O0004213O002100012O0061000300034O005E000400046O00058O000600036O00040006000100122O000400033O00202O0004000400044O000500056O0004000200014O000400066O00058O000600026O00040006000100044O002100010004213O000A00012O00AF3O00019O002O0001054O006100015O0006BA0001000400013O0004213O000400012O00193O00014O00AF3O00019O002O0001024O00198O00AF3O00019O002O0001024O00198O00AF3O00019O002O0001054O006100015O0006BA0001000400013O0004213O000400012O00193O00014O00AF3O00017O00043O0003083O004D79546F2O676C6503053O0056616C7565028O00030D3O004D61676E657473416D6F756E7400154O00617O0020B35O00010020B35O00020006BA3O001200013O0004213O001200010012243O00034O006C000100013O00260F3O0007000100030004213O000700012O006100025O00203C00020002000400202O0001000200024O000200016O000300016O00020002000100044O001400010004213O000700010004213O001400012O00613O00024O00403O000100012O00AF3O00017O00083O00028O00030A3O00636F2O6E656374696F6E030A3O00446973636F2O6E65637403043O0067616D65030A3O0047657453657276696365030A3O0052756E5365727669636503093O0048656172746265617403073O00436F2O6E65637400173O0012243O00013O00260F3O0001000100010004213O00010001001228000100023O0006BA0001000900013O0004213O00090001001228000100023O0020080001000100032O002B000100020001001228000100043O00203400010001000500122O000300066O00010003000200202O00010001000700202O00010001000800065100033O000100022O00618O00613O00014O005400010003000200123B000100023O0004213O001600010004213O000100012O00AF3O00013O00013O001B3O0003023O005F47030A3O0050752O6C566563746F7203063O0069706169727303093O00776F726B7370616365030B3O004765744368696C6472656E03043O004E616D6503083O00462O6F7462612O6C03083O0056656C6F6369747903093O004D61676E6974756465027O004003043O0067616D65030A3O004765745365727669636503073O00506C6179657273030B3O004C6F63616C506C6179657203093O00436861726163746572030E3O0046696E6446697273744368696C6403103O0048756D616E6F6964522O6F7450617274028O0003083O00506F736974696F6E03083O00746F6E756D62657203123O0050752O6C566563746F7244697374616E636503083O00476574537461746503043O00456E756D03113O0048756D616E6F696453746174655479706503083O0046722O6566612O6C03043O00556E6974030F3O0050752O6C566563746F72466F726365004A3O0012283O00013O0020B35O00020006BA3O004900013O0004213O004900012O00617O0006BB3O0049000100010004213O004900010012283O00033O00122A000100043O00202O0001000100054O000100029O00000200044O004700010020B300050004000600260F00050047000100070004213O004700010020B30005000400080020B3000500050009000E07000A0047000100050004213O004700010012280005000B3O00201500050005000C00122O0007000D6O00050007000200202O00050005000E00202O00050005000F00202O00050005001000122O000700116O00050007000200062O0005004700013O0004213O00470001001224000600124O006C000700073O00260F00060021000100120004213O002100010020B30008000400130020750009000500134O00080008000900202O00070008000900122O000800143O00122O000900013O00202O0009000900154O00080002000200062O00070047000100080004213O004700012O0061000800013O0020090008000800164O00080002000200122O000900173O00202O00090009001800202O00090009001900062O00080047000100090004213O00470001001224000800124O006C000900093O00260F00080037000100120004213O003700010020B3000A000400130020B9000B000500134O000A000A000B00202O0009000A001A00122O000A00143O00122O000B00013O00202O000B000B001B4O000A000200024O000A0009000A00102O00050008000A00044O004700010004213O003700010004213O004700010004213O002100010006AC3O000D000100020004213O000D00012O00AF3O00017O00073O00028O0003023O005F47030A3O0050752O6C566563746F7203103O0050752O6C566563746F72546F2O676C6503053O0056616C7565030A3O00636F2O6E656374696F6E030A3O00446973636F2O6E65637400253O0012243O00013O00260F3O0001000100010004213O00010001001228000100024O008500025O00202O00020002000400202O00020002000500102O00010003000200122O000100023O00202O00010001000300062O0001000F00013O0004213O000F00012O0061000100014O00400001000100010004213O00240001001228000100063O0006BA0001002400013O0004213O00240001001224000100014O006C000200023O000E8900010014000100010004213O00140001001224000200013O00260F00020017000100010004213O00170001001228000300063O00204B0003000300074O0003000200014O000300033O00122O000300063O00044O002400010004213O001700010004213O002400010004213O001400010004213O002400010004213O000100012O00AF3O00017O00033O0003023O005F4703123O0050752O6C566563746F7244697374616E636503083O00746F6E756D62657201063O001226000100013O00122O000200036O00038O00020002000200102O0001000200026O00019O002O002O014O00AF3O00017O00033O0003023O005F47030F3O0050752O6C566563746F72466F72636503083O00746F6E756D62657201063O001226000100013O00122O000200036O00038O00020002000200102O0001000200026O00019O002O002O014O00AF3O00017O00293O00028O0003083O00496E7374616E63652O033O006E657703093O005363722O656E47756903093O00506C61796572477569030A3O005465787442752O746F6E03043O0053697A6503053O005544696D32030A3O0066726F6D4F2O66736574026O005E40026O004E4003083O00506F736974696F6E03093O0066726F6D5363616C65026O00E03F02CD5OCCEC3F026O003E40026O00F03F026O001040026O00084003083O005465787453697A65026O003840030F3O004175746F42752O746F6E436F6C6F72010003073O0056697369626C6503063O00506172656E74027O0040030C3O00426F72646572436F6C6F723303063O00436F6C6F723303073O0066726F6D524742025O00E06F4003163O00546578745374726F6B655472616E73706172656E6379029A5O99E93F03103O00546578745374726F6B65436F6C6F723303043O00466F6E7403043O00456E756D030A3O00476F7468616D426F6C6403043O005465787403023O005450030A3O0054657874436F6C6F723303103O004261636B67726F756E64436F6C6F7233030F3O00426F7264657253697A65506978656C00583O0012243O00014O006C000100023O00260F3O0023000100010004213O00230001001228000300023O00203200030003000300122O000400046O00055O00202O0005000500054O0003000500024O000100033O00122O000300023O00202O00030003000300122O000400066O0003000200024O000200033O00122O000300083O00202O00030003000900122O0004000A3O00122O0005000B6O00030005000200102O00020007000300122O000300083O00202O00030003000D00122O0004000E3O00122O0005000F6O00030005000200122O000400083O00202O00040004000900122O0005000B3O00122O000600106O0004000600024O00030003000400102O0002000C000300124O00113O00260F3O0026000100120004213O002600012O005C000200023O00260F3O002D000100130004213O002D00010030740002001400150030740002001600170030740002001800170010630002001900010012243O00123O00260F3O00430001001A0004213O004300010012280003001C3O002O2000030003001D00122O0004001E3O00122O0005001E3O00122O0006001E6O00030006000200102O0002001B000300302O0002001F002000122O0003001C3O00202O00030003001D00122O000400013O00122O000500013O00122O000600016O00030006000200102O00020021000300122O000300233O00202O00030003002200202O00030003002400102O00020022000300124O00133O00260F3O0002000100110004213O000200010030740002002500260012B50003001C3O00202O00030003001D00122O0004001E3O00122O0005001E3O00122O0006001E6O00030006000200102O00020027000300122O0003001C3O00202O00030003001D00122O000400013O00122O000500013O00122O000600016O00030006000200102O00020028000300302O00020029001A00124O001A3O00044O000200012O00AF3O00017O00083O00030F3O0057616C6B53702O6564546F2O676C6503053O0056616C756503043O0067616D6503073O00506C6179657273030B3O004C6F63616C506C6179657203093O0043686172616374657203083O0048756D616E6F696403093O0057616C6B53702O6564010C4O006100015O0020B30001000100010020B30001000100020006BA0001000B00013O0004213O000B0001001228000100033O00206800010001000400202O00010001000500202O00010001000600202O00010001000700102O000100084O00AF3O00017O00083O00030F3O0057616C6B53702O6564546F2O676C6503053O0056616C756503043O0067616D6503073O00506C6179657273030B3O004C6F63616C506C6179657203093O0043686172616374657203083O0048756D616E6F696403093O0057616C6B53702O6564010C4O006100015O0020B30001000100010020B30001000100020006BA0001000B00013O0004213O000B0001001228000100033O00206800010001000400202O00010001000500202O00010001000600202O00010001000700102O000100084O00AF3O00017O00083O00030F3O004A756D70506F776572546F2O676C6503053O0056616C756503043O0067616D6503073O00506C6179657273030B3O004C6F63616C506C6179657203093O0043686172616374657203083O0048756D616E6F696403093O004A756D70506F776572010C4O006100015O0020B30001000100010020B30001000100020006BA0001000B00013O0004213O000B0001001228000100033O00206800010001000400202O00010001000500202O00010001000600202O00010001000700102O000100084O00AF3O00017O00083O00030F3O004A756D70506F776572546F2O676C6503053O0056616C756503043O0067616D6503073O00506C6179657273030B3O004C6F63616C506C6179657203093O0043686172616374657203083O0048756D616E6F696403093O004A756D70506F776572010C4O006100015O0020B30001000100010020B30001000100020006BA0001000B00013O0004213O000B0001001228000100033O00206800010001000400202O00010001000500202O00010001000600202O00010001000700102O000100084O00AF3O00017O00063O00028O0003053O007061697273030A3O00476574506C617965727303093O00436861726163746572030E3O0046696E6446697273744368696C6403083O00462O6F7462612O6C001F3O0012243O00014O006C000100013O00260F3O0002000100010004213O00020001001224000100013O00260F00010005000100010004213O00050001001228000200024O000E00035O00202O0003000300034O000300046O00023O000400044O001700010020B30007000600040006BA0007001700013O0004213O001700010020B3000700060004002008000700070005001224000900064O00540007000900020006BA0007001700013O0004213O001700012O005C000600023O0006AC0002000D000100020004213O000D00012O006C000200024O005C000200023O0004213O000500010004213O001E00010004213O000200012O00AF3O00017O00023O0003083O0056656C6F6369747903083O00506F736974696F6E02063O00209E00023O000100202O00033O00024O0004000200014O0003000300044O000300028O00017O000F3O0003023O005F4703083O004175746F52757368028O00026O00F03F03043O0077616974029A5O99B93F03093O00436861726163746572030E3O0046696E6446697273744368696C6403103O0048756D616E6F6964522O6F745061727403093O004D61676E697475646503083O0048756D616E6F696403063O004D6F7665546F03043O004D6F766503073O00566563746F72332O033O006E657701533O001228000100013O0020B30001000100020006BA0001005200013O0004213O00520001001224000100034O006C000200023O00260F0001000C000100040004213O000C0001001228000300053O001224000400064O002B0003000200010004215O000100260F00010006000100030004213O000600012O006100036O008B0003000100022O006A000200033O0006BA0002004300013O0004213O00430001001224000300034O006C000400063O00260F00030036000100040004213O003600010020B300070002000700064D0006001F000100070004213O001F00010020B3000700020007002008000700070008001224000900094O00540007000900022O006A000600073O0006BA0005004F00013O0004213O004F00010006BA0006004F00013O0004213O004F0001001224000700034O006C000800083O00260F00070025000100030004213O002500012O0061000900014O00BF000A00066O000B8O0009000B00024O000800093O00202O00090008000A000E2O0003004F000100090004213O004F00010020B300090004000B00200800090009000C2O006A000B00084O00790009000B00010004213O004F00010004213O002500010004213O004F000100260F00030015000100030004213O001500012O0061000700023O0020B300040007000700064D00050040000100040004213O00400001002008000700040008001224000900094O00540007000900022O006A000500073O001224000300043O0004213O001500010004213O004F00012O0061000300023O00203A00030003000700202O00030003000B00202O00030003000D00122O0005000E3O00202O00050005000F00122O000600033O00122O000700033O00122O000800036O0005000800024O000600016O000300060001001224000100043O0004213O000600010004215O00012O00AF3O00017O00073O00028O0003023O005F4703083O004175746F52757368030E3O004175746F52757368546F2O676C6503053O0056616C756503093O005275736844656C617903053O00737061776E00243O0012243O00014O006C000100013O00260F3O0002000100010004213O00020001001224000100013O00260F00010005000100010004213O00050001001228000200024O008500035O00202O00030003000400202O00030003000500102O00020003000300122O000200023O00202O00020002000300062O0002002300013O0004213O00230001001224000200014O006C000300033O00260F00020012000100010004213O001200012O006100045O0020B30004000400060020B3000300040005001228000400073O00065100053O000100022O00613O00014O006A3O00034O002B0004000200010004213O001E00010004213O001200012O006600025O0004213O002300010004213O000500010004213O002300010004213O000200012O00AF3O00013O00018O00044O00618O0061000100014O002B3O000200012O00AF3O00017O00093O0003023O005F4703083O004175746F52757368028O00010003043O0077616974029A5O99C93F026O00F03F2O0103053O00737061776E01193O001228000100013O0020B30001000100020006BA0001001800013O0004213O00180001001224000100033O000E890003000D000100010004213O000D0001001228000200013O00308200020002000400122O000200053O00122O000300066O00020002000100122O000100073O00260F00010005000100070004213O00050001001228000200013O003074000200020008001228000200093O00065100033O000100022O00618O006A8O002B0002000200010004213O001800010004213O000500012O00AF3O00013O00018O00044O00618O0061000100014O002B3O000200012O00AF3O00019O002O002O014O00AF3O00017O000F3O00028O0003073O00506C617965727303043O0067616D65030A3O0047657453657276696365026O00F03F03113O005265706C69636174656453746F7261676503103O0055736572496E70757453657276696365027O004003063O00436C69656E74030B3O004C6F63616C506C6179657203093O00436861726163746572030E3O00436861726163746572412O64656403043O0057616974026O00084003073O00436F2O6E65637400333O0012243O00014O006C000100013O00260F3O000C000100010004213O000C00012O00B600026O00B8000100023O00122O000200033O00202O00020002000400122O000400026O00020004000200102O00010002000200124O00053O00260F3O0019000100050004213O00190001001228000200033O00202300020002000400122O000400066O00020004000200102O00010006000200122O000200033O00202O00020002000400122O000400076O00020004000200102O00010007000200124O00083O00260F3O0028000100080004213O002800010020B30002000100020020AD00020002000A00102O00010009000200202O00020001000900202O00020002000B00062O00020026000100010004213O002600010020B30002000100090020B300020002000C00200800020002000D2O00B40002000200020010630001000B00020012243O000E3O00260F3O00020001000E0004213O000200010020B30002000100090020B300020002000C00200800020002000F00065100043O000100012O006A3O00014O00790002000400012O005C000100023O0004213O000200012O00AF3O00013O00013O00013O0003093O0043686172616374657201034O006100015O001063000100014O00AF3O00017O00063O00028O00026O00F03F03053O00706169727303083O00506F736974696F6E03013O005903053O005363616C6501333O001224000100014O006C000200043O00260F0001002C000100020004213O002C00012O006C000400043O001224000500013O00260F00050006000100010004213O0006000100260F0002000D000100010004213O000D0001001224000300014O006C000400043O001224000200023O00260F00020005000100020004213O00050001001224000600013O00260F00060010000100010004213O00100001001228000700034O006A00086O00770007000200090004213O002400010020B3000C000B00040020B3000C000C00050020B3000C000C0006000652000300240001000C0004213O00240001001224000C00013O000E890001001C0001000C0004213O001C00010020B3000D000B00040020B3000D000D00050020B30003000D00062O006A0004000B3O0004213O002400010004213O001C00010006AC00070016000100020004213O001600012O005C000400023O0004213O001000010004213O000500010004213O000600010004213O000500010004213O0032000100260F00010002000100010004213O00020001001224000200014O006C000300033O001224000100023O0004213O000200012O00AF3O00017O000B3O00028O0003063O0069706169727303093O00776F726B7370616365030E3O0047657444657363656E64616E74732O033O0049734103083O004261736550617274030A3O0043616E436F2O6C6964652O0103053O007461626C6503063O00696E73657274026O00F03F01213O001224000100014O006C000200023O00260F0001001C000100010004213O001C00012O00B600036O0017000200033O00122O000300023O00122O000400033O00202O0004000400044O000400056O00033O000500044O00190001002008000800070005001224000A00064O00540008000A00020006BA0008001900013O0004213O001900010020B300080007000700260F00080019000100080004213O00190001001228000800093O0020B300080008000A2O006A000900024O006A000A00074O00790008000A00010006AC0003000C000100020004213O000C00010012240001000B3O00260F000100020001000B0004213O000200012O005C000200023O0004213O000200012O00AF3O00017O00063O0003053O00706169727303093O00776F726B7370616365030B3O004765744368696C6472656E03043O004E616D65030B3O004265616D5365676D656E7403073O0044657374726F79010E3O0012AE000100013O00122O000200023O00202O0002000200034O000200036O00013O000300044O000B00010020B300060005000400260F0006000B000100050004213O000B00010020080006000500062O002B0006000200010006AC00010006000100020004213O000600012O00AF3O00017O00363O00028O00026O00F03F03063O00506172616D73031A3O0046696C74657244657363656E64616E7473496E7374616E636573030E3O00476574436F2O6C696461626C6573027O004003063O0069706169727303043O0067616D6503073O00436F7265477569030B3O004765744368696C6472656E2O033O0049734103093O00486967686C6967687403073O0041646F726E2O6503043O0077616974026O00104003073O0044657374726F7903083O00496E7374616E63652O033O006E657703093O0044657074684D6F646503043O00456E756D03123O00486967686C6967687444657074684D6F6465030B3O00416C776179734F6E546F7003073O00456E61626C65642O01030C3O004F75746C696E65436F6C6F7203073O005365676D656E7403053O00436F6C6F7203133O004F75746C696E655472616E73706172656E6379030C3O005472616E73706172656E637903093O0046692O6C436F6C6F7203063O00436F6C6F723303073O0066726F6D524742025O00E06F4003103O0046692O6C5472616E73706172656E6379026O66E63F03113O0056697375616C697A6572456E61626C656403083O00436173745374657003073O00566563746F7233026O002C4003053O00436C6F6E6503083O00506F736974696F6E03043O0053697A65029A5O99C93F03093O006D61676E697475646503063O00434672616D6503013O005A03063O00506172656E7403093O00776F726B737061636503043O007461736B03053O0064656C6179030F3O005365676D656E744C69666574696D6503153O0046696E6446697273744368696C644F66436C612O7303093O00426F6479466F726365030B3O00576970654D61726B65727304AF3O001224000400014O006C000500073O00260F0004000F000100010004213O000F0001001224000800013O00260F0008000A000100010004213O000A0001001224000500014O006A000600013O001224000800023O00260F00080005000100020004213O00050001001224000400023O0004213O000F00010004213O00050001000E8900020017000100040004213O001700010020B300083O000300209000093O00054O00090002000200102O0008000400094O000700073O00122O000400063O00260F00040002000100060004213O000200010006BA0003005300013O0004213O00530001001228000800073O001262000900083O00202O00090009000900202O00090009000A4O0009000A6O00083O000A00044O00340001002008000D000C000B001224000F000C4O0054000D000F00020006BA000D003400013O0004213O003400010020B3000D000C000D00068C000D0034000100030004213O00340001001224000D00013O000E890001002B0001000D0004213O002B0001001228000E000E3O0012A8000F000F6O000E0002000100202O000E000C00104O000E0002000100044O003400010004213O002B00010006AC00080022000100020004213O00220001001228000800113O00203800080008001200122O0009000C3O00122O000A00083O00202O000A000A00094O0008000A00024O000700083O00102O0007000D000300122O000800143O00202O00080008001500202O00080008001600102O00070013000800302O0007001700184O00085O00202O00080008001A00202O00080008001B00102O0007001900084O00085O00202O00080008001A00202O00080008001D00102O0007001C000800122O0008001F3O00202O00080008002000122O000900213O00122O000A00213O00122O000B00216O0008000B000200102O0007001E000800302O0007002200232O006100085O0020B30008000800240006BA000800AE00013O0004213O00AE00012O006100085O0020500008000800254O0005000500084O0008000200054O00080001000800122O000900263O00202O00090009001200122O000A00013O00202O000B0005000600102O000B0027000B00122O000C00016O0009000C00024O00080008000900202O00093O001A00202O0009000900284O0009000200024O000A0006000800202O000A000A000600102O00090029000A00122O000A00263O00202O000A000A001200122O000B002B3O00122O000C002B6O000D0006000800202O000D000D002C4O000A000D000200102O0009002A000A00122O000A002D3O00202O000A000A00124O000B00066O000C00086O000A000C000200122O000B002D3O00202O000B000B001200122O000C00013O00122O000D00013O00202O000E0009002A00202O000E000E002E4O000E000E3O00202O000E000E00064O000B000E00024O000A000A000B00102O0009002D000A4O000A5O00202O000A000A001A00202O000A000A001B00102O0009001B000A4O000A5O00202O000A000A001A00202O000A000A001D00102O0009001D000A00122O000A00303O00102O0009002F000A00122O000A00313O00202O000A000A00324O000B5O00202O000B000B0033000651000C3O000100012O006A3O00094O0079000A000C00012O006A000600083O0006BA000300A700013O0004213O00A700010006BA000700A700013O0004213O00A700010020B3000A0003002F001228000B00303O00068C000A00A10001000B0004213O00A10001002008000A00030034001224000C00354O0054000A000C00020006BB000A00A7000100010004213O00A70001002008000A000700102O005F000A0002000100202O000A3O00364O000A000200014O00085O00044O00AE0001001228000A00313O0020B3000A000A000E2O0040000A000100012O006600085O0004213O005300010004213O00AE00010004213O000200012O00AF3O00013O00013O00023O0003063O00506172656E7403073O0044657374726F79000B4O00617O0006BA3O000A00013O0004213O000A00012O00617O0020B35O00010006BA3O000A00013O0004213O000A00012O00617O0020085O00022O002B3O000200012O00AF3O00017O00023O0003113O0056697375616C697A6572456E61626C65643O01034O006100015O0030740001000100022O00AF3O00017O00043O00028O0003113O0056697375616C697A6572456E61626C65640100030B3O00576970654D61726B65727301113O001224000100014O006C000200023O00260F00010002000100010004213O00020001001224000200013O00260F00020005000100010004213O000500012O006100035O00305A0003000200034O00035O00202O0003000300044O00030002000100044O001000010004213O000500010004213O001000010004213O000200012O00AF3O00017O00083O0003043O004E616D6503083O00462O6F7462612O6C2O033O0049734103083O004261736550617274028O0003183O0047657450726F70657274794368616E6765645369676E616C03083O0056656C6F6369747903073O00436F2O6E656374011B3O0020B300013O000100260F0001001A000100020004213O001A000100200800013O0003001224000300044O00540001000300020006BA0001001A00013O0004213O001A0001001224000100054O006C000200023O00260F0001000A000100050004213O000A00012O006C000200023O00200800033O0006001224000500074O005400030005000200200800030003000800065100053O000100032O00618O006A8O006A3O00024O00540003000500022O006A000200033O0004213O001900010004213O000A00012O006600016O00AF3O00013O00013O00063O00028O0003113O0056697375616C697A6572456E61626C6564030A3O004765744C616E64696E6703083O00506F736974696F6E03083O0056656C6F63697479030A3O00446973636F2O6E656374001B3O0012243O00014O006C000100013O00260F3O0002000100010004213O00020001001224000100013O00260F00010005000100010004213O000500012O006100025O0020B30002000200020006BA0002001300013O0004213O001300012O006100025O0020A40002000200034O000400013O00202O0004000400044O000500013O00202O0005000500054O000600016O0002000600012O0061000200023O0020080002000200062O002B0002000200010004213O001A00010004213O000500010004213O001A00010004213O000200012O00AF3O00017O00033O0003053O0056616C7565030F3O00537461727456697375616C697A6572030E3O0053746F7056697375616C697A6572000C4O00617O0020B35O00010006BA3O000800013O0004213O000800012O00613O00013O0020085O00022O002B3O000200010004213O000B00012O00613O00013O0020085O00032O002B3O000200012O00AF3O00017O00193O00028O00026O00F03F03063O0069706169727303093O00776F726B7370616365030B3O004765744368696C6472656E03043O004E616D65030B3O004265616D5365676D656E7403053O00436F6C6F7203053O0056616C7565030C3O005472616E73706172656E637903043O0067616D6503073O00436F72654775692O033O0049734103093O00486967686C6967687403073O0041646F726E2O6503083O00462O6F7462612O6C03093O0046692O6C436F6C6F7203063O00436F6C6F723303073O0066726F6D524742025O00E06F4003103O0046692O6C5472616E73706172656E6379026O66E63F030C3O004F75746C696E65436F6C6F7203133O004F75746C696E655472616E73706172656E637903073O005365676D656E74005A3O0012243O00014O006C000100013O00260F3O0002000100010004213O00020001001224000100013O000E8900020049000100010004213O00490001001228000200033O00122A000300043O00202O0003000300054O000300046O00023O000400044O001B00010020B300070006000600260F0007001B000100070004213O001B0001001224000700013O000E8900010011000100070004213O001100012O006100085O00201800080008000900102O0006000800084O00085O00202O00080008000A00102O0006000A000800044O001B00010004213O001100010006AC0002000D000100020004213O000D0001001228000200033O0012620003000B3O00202O00030003000C00202O0003000300054O000300046O00023O000400044O0046000100200800070006000D0012240009000E4O00540007000900020006BA0007004600013O0004213O004600010020B300070006000F0006BA0007004600013O0004213O004600010020B300070006000F0020B300070007000600260F00070046000100100004213O00460001001224000700013O00260F0007003C000100020004213O003C0001001228000800123O0020A600080008001300122O000900143O00122O000A00143O00122O000B00146O0008000B000200102O00060011000800302O00060015001600044O0046000100260F00070031000100010004213O003100012O006100085O00202700080008000900102O0006001700084O00085O00202O00080008000A00102O00060018000800122O000700023O00044O003100010006AC00020024000100020004213O002400010004213O0059000100260F00010005000100010004213O000500012O0061000200013O0020A20002000200194O00035O00202O00030003000900102O0002000800034O000200013O00202O0002000200194O00035O00202O00030003000A00102O0002000A000300122O000100023O00044O000500010004213O005900010004213O000200012O00AF3O00017O00193O00028O0003043O006E65787403043O0067616D65030E3O0047657444657363656E64616E7473027O00402O033O004973412O033O00536B7903063O00506172656E74026O00F03F030B3O00426C2O6F6D452O66656374030A3O00426C7572452O6665637403123O0044657074684F664669656C64452O66656374030D3O0053756E52617973452O6665637403073O00456E61626C656403053O00446563616C03073O005465787475726503043O005061727403053O00556E696F6E03083O00426173655061727403083O004D6174657269616C030F3O005061727469636C65456D692O74657203053O00536D6F6B6503093O004578706C6F73696F6E03083O00537061726B6C657303043O004669726500983O0012243O00014O006C000100013O00260F3O0002000100010004213O00020001001224000100013O00260F00010005000100010004213O000500012O00B600026O006E00025O00122O000200023O00122O000300033O00202O0003000300044O00030002000400044O00910001001224000700013O00260F00070020000100050004213O00200001002008000800060006001224000A00074O00540008000A00020006BA0008009100013O0004213O009100012O006100086O00530008000800060006BB00080091000100010004213O009100012O006100086O007000093O000100202O000A0006000800102O00090008000A4O00080006000900044O0091000100260F00070053000100090004213O00530001002008000800060006001224000A000A4O00540008000A00020006BB00080036000100010004213O00360001002008000800060006001224000A000B4O00540008000A00020006BB00080036000100010004213O00360001002008000800060006001224000A000C4O00540008000A00020006BB00080036000100010004213O00360001002008000800060006001224000A000D4O00540008000A00020006BA0008003F00013O0004213O003F00012O006100086O00530008000800060006BB0008003F000100010004213O003F00012O006100086O00B600093O00010020B3000A0006000E0010630009000E000A2O009F000800060009002008000800060006001224000A000F4O00540008000A00020006BB00080049000100010004213O00490001002008000800060006001224000A00104O00540008000A00020006BA0008005200013O0004213O005200012O006100086O00530008000800060006BB00080052000100010004213O005200012O006100086O00B600093O00010020B3000A0006001000106300090010000A2O009F000800060009001224000700053O00260F0007000F000100010004213O000F0001002008000800060006001224000A00114O00540008000A00020006BB00080064000100010004213O00640001002008000800060006001224000A00124O00540008000A00020006BB00080064000100010004213O00640001002008000800060006001224000A00134O00540008000A00020006BA0008006D00013O0004213O006D00012O006100086O00530008000800060006BB0008006D000100010004213O006D00012O006100086O00B600093O00010020B3000A0006001400106300090014000A2O009F000800060009002008000800060006001224000A00154O00540008000A00020006BB00080086000100010004213O00860001002008000800060006001224000A00164O00540008000A00020006BB00080086000100010004213O00860001002008000800060006001224000A00174O00540008000A00020006BB00080086000100010004213O00860001002008000800060006001224000A00184O00540008000A00020006BB00080086000100010004213O00860001002008000800060006001224000A00194O00540008000A00020006BA0008008F00013O0004213O008F00012O006100086O00530008000800060006BB0008008F000100010004213O008F00012O006100086O00B600093O00010020B3000A0006000E0010630009000E000A2O009F000800060009001224000700093O0004213O000F00010006AC0002000E000100020004213O000E00010004213O009700010004213O000500010004213O009700010004213O000200012O00AF3O00017O00173O0003053O007061697273028O00026O00F03F2O033O00497341030B3O00426C2O6F6D452O66656374030A3O00426C7572452O6665637403123O0044657074684F664669656C64452O66656374030D3O0053756E52617973452O6665637403073O00456E61626C656403053O00446563616C03073O0054657874757265027O004003043O005061727403053O00556E696F6E03083O00426173655061727403083O004D6174657269616C030F3O005061727469636C65456D692O74657203053O00536D6F6B6503093O004578706C6F73696F6E03083O00537061726B6C657303043O00466972652O033O00536B7903063O00506172656E74006F3O0012283O00014O006100016O00773O000200020004213O006C00010006BA0003006C00013O0004213O006C0001001224000500024O006C000600063O000E8900020008000100050004213O00080001001224000600023O000E8900030030000100060004213O00300001002008000700030004001224000900054O00540007000900020006BB00070021000100010004213O00210001002008000700030004001224000900064O00540007000900020006BB00070021000100010004213O00210001002008000700030004001224000900074O00540007000900020006BB00070021000100010004213O00210001002008000700030004001224000900084O00540007000900020006BA0007002300013O0004213O002300010020B30007000400090010630003000900070020080007000300040012240009000A4O00540007000900020006BB0007002D000100010004213O002D00010020080007000300040012240009000B4O00540007000900020006BA0007002F00013O0004213O002F00010020B300070004000B0010630003000B00070012240006000C3O00260F0006005F000100020004213O005F00010020080007000300040012240009000D4O00540007000900020006BB00070041000100010004213O004100010020080007000300040012240009000E4O00540007000900020006BB00070041000100010004213O004100010020080007000300040012240009000F4O00540007000900020006BA0007004300013O0004213O004300010020B3000700040010001063000300100007002008000700030004001224000900114O00540007000900020006BB0007005C000100010004213O005C0001002008000700030004001224000900124O00540007000900020006BB0007005C000100010004213O005C0001002008000700030004001224000900134O00540007000900020006BB0007005C000100010004213O005C0001002008000700030004001224000900144O00540007000900020006BB0007005C000100010004213O005C0001002008000700030004001224000900154O00540007000900020006BA0007005E00013O0004213O005E00010020B3000700040009001063000300090007001224000600033O00260F0006000B0001000C0004213O000B0001002008000700030004001224000900164O00540007000900020006BA0007006C00013O0004213O006C00010020B30007000400170010630003001700070004213O006C00010004213O000B00010004213O006C00010004213O000800010006AC3O0004000100020004213O000400012O00AF3O00017O002F3O0003043O006E65787403043O0067616D65030E3O0047657444657363656E64616E7473028O00026O00F03F2O033O00497341030B3O00426C2O6F6D452O66656374030A3O00426C7572452O6665637403123O0044657074684F664669656C64452O66656374030D3O0053756E52617973452O6665637403073O00456E61626C6564010003053O00446563616C03073O0054657874757265034O00027O00402O033O00536B7903063O00506172656E740003043O005061727403053O00556E696F6E03083O00426173655061727403083O004D6174657269616C03043O00456E756D030D3O00536D2O6F7468506C6173746963030F3O005061727469636C65456D692O74657203053O00536D6F6B6503093O004578706C6F73696F6E03083O00537061726B6C657303043O0046697265030A3O004765745365727669636503083O004C69676874696E6703083O00466F67436F6C6F7203063O00436F6C6F723303073O0066726F6D524742026O00694003063O00466F67456E64025O00408F4003083O00466F675374617274025O00407F4003073O00416D6269656E74030A3O004272696768746E652O7303113O00436F6C6F7253686966745F426F2O746F6D030E3O00436F6C6F7253686966745F546F70030E3O004F7574642O6F72416D6269656E7403083O004F75746C696E65732O0100973O0012223O00013O00122O000100023O00202O0001000100034O00010002000200044O00690001001224000500044O006C000600063O000E8900040007000100050004213O00070001001224000600043O00260F0006002D000100050004213O002D0001002008000700040006001224000900074O00540007000900020006BB00070020000100010004213O00200001002008000700040006001224000900084O00540007000900020006BB00070020000100010004213O00200001002008000700040006001224000900094O00540007000900020006BB00070020000100010004213O002000010020080007000400060012240009000A4O00540007000900020006BA0007002100013O0004213O002100010030740004000B000C0020080007000400060012240009000D4O00540007000900020006BB0007002B000100010004213O002B00010020080007000400060012240009000E4O00540007000900020006BA0007002C00013O0004213O002C00010030740004000E000F001224000600103O00260F00060036000100100004213O00360001002008000700040006001224000900114O00540007000900020006BA0007006900013O0004213O006900010030740004001200130004213O0069000100260F0006000A000100040004213O000A0001002008000700040006001224000900144O00540007000900020006BB00070047000100010004213O00470001002008000700040006001224000900154O00540007000900020006BB00070047000100010004213O00470001002008000700040006001224000900164O00540007000900020006BA0007004B00013O0004213O004B0001001228000700183O0020B30007000700170020B30007000700190010630004001700070020080007000400060012240009001A4O00540007000900020006BB00070064000100010004213O006400010020080007000400060012240009001B4O00540007000900020006BB00070064000100010004213O006400010020080007000400060012240009001C4O00540007000900020006BB00070064000100010004213O006400010020080007000400060012240009001D4O00540007000900020006BB00070064000100010004213O006400010020080007000400060012240009001E4O00540007000900020006BA0007006500013O0004213O006500010030740004000B000C001224000600053O0004213O000A00010004213O006900010004213O000700010006AC3O0005000100020004213O000500010012283O00023O0020A15O001F00122O000200208O0002000200122O000100223O00202O00010001002300122O000200243O00122O000300243O00122O000400246O00010004000200104O0021000100304O0025002600304O0027002800122O000100223O00202O00010001002300122O000200243O00122O000300243O00122O000400246O00010004000200104O0029000100304O002A001000122O000100223O00202O00010001002300122O000200243O00122O000300243O00122O000400246O00010004000200104O002B000100122O000100223O00202O00010001002300122O000200243O00122O000300243O00122O000400246O00010004000200104O002C000100122O000100223O00202O00010001002300122O000200243O00122O000300243O00122O000400246O00010004000200104O002D000100304O002E002F6O00017O00023O0003053O0056616C7565029O00214O00617O0020B35O00010006BA3O000E00013O0004213O000E00012O00613O00013O0006BB3O0020000100010004213O002000012O00613O00024O001E3O000100016O00038O000100016O00018O00013O00044O002000012O00613O00013O0006BA3O002000013O0004213O002000010012243O00024O006C000100013O000E890002001300013O0004213O00130001001224000100023O00260F00010016000100020004213O001600012O0061000200044O00400002000100012O009200026O0019000200013O0004213O002000010004213O001600010004213O002000010004213O001300012O00AF3O00017O00233O00028O00026O00F03F03023O005F4703053O0041646D696E03093O00416E746941646D696E03053O0056616C756503133O0032363138393337322O33353033392O3437323703123O0032303931382O37382O3037393634382O373803123O0032362O354O34373132393831322O393203123O00362O37393634362O3538323133323433323903123O003436393034333639382O313035363233303403123O0037393231342O35363835383637393239373903123O0034393035332O37393639342O30373039313503123O00363738362O3930342O382O3431333233363203123O0038333735312O34313534383038393736303703123O0034313731342O312O3935363439363338343003123O0035383031343035363332393531303931343803123O003233312O323532383937313834393732383103123O003731393235383233363933302O323833343603123O00333435333632393530333830332O3238323903123O003531333139363536343233363436382O323603123O0032343139343532313234363337343239383603123O0031352O33373934373031363436322O333630030A3O002O31373034333932363403043O0067616D65030A3O004765745365727669636503073O00506C6179657273030A3O00476574506C617965727303063O0069706169727303053O007461626C6503043O0066696E6403063O005573657249642O0103043O004B69636B03193O0041646D696E204A6F696E65642028416E74692D41646D696E2900493O0012243O00014O006C000100033O00260F3O0042000100020004213O004200012O006C000300033O00260F00010022000100010004213O00220001001228000400034O001400055O00202O00050005000500202O00050005000600102O0004000400054O000400113O00122O000500073O00122O000600083O00122O000700093O00122O0008000A3O00122O0009000B3O00122O000A000C3O00122O000B000D3O00122O000C000E3O00122O000D000F3O00122O000E00103O00122O000F00113O00122O001000123O00122O001100133O00122O001200143O00122O001300153O00122O001400163O00122O001500173O00122O001600186O0004001200012O006A000200043O001224000100023O00260F00010005000100020004213O00050001001228000400193O00205600040004001A00122O0006001B6O00040006000200202O00040004001C4O0004000200024O000300043O00122O0004001D6O000500036O00040002000600044O003D00010012280009001E3O00208000090009001F4O000A00023O00202O000B000800204O0009000B000200062O0009003D00013O0004213O003D0001001228000900033O0020B300090009000400260F0009003D000100210004213O003D0001002008000900080022001224000B00234O00790009000B00010006AC0004002F000100020004213O002F00010004213O004800010004213O000500010004213O0048000100260F3O0002000100010004213O00020001001224000100014O006C000200023O0012243O00023O0004213O000200012O00AF3O00017O00163O0003063O0069706169727303043O0067616D6503093O00576F726B7370616365030B3O004765744368696C6472656E03043O004E616D6503083O00462O6F7462612O6C030A3O004765745365727669636503073O00506C6179657273030B3O004C6F63616C506C6179657203093O0043686172616374657203023O005F47030A3O0050752O6C566563746F722O01028O0003083O00506F736974696F6E030E3O0046696E6446697273744368696C6403103O0048756D616E6F6964522O6F745061727403043O00556E697403093O004D61676E6974756465026O00F03F03123O0050752O6C566563746F7244697374616E636503083O0056656C6F63697479004D3O0012013O00013O00122O000100023O00202O00010001000300202O0001000100044O000100029O00000200044O004A00010020B300050004000500260F0005004A000100060004213O004A0001001228000500023O00209900050005000700122O000700086O00050007000200202O00050005000900202O00050005000A00062O0005004A00013O0004213O004A00010012280005000B3O0020B300050005000C00260F0005004A0001000D0004213O004A00010012240005000E4O006C000600073O00260F000500350001000E0004213O003500010020B300080004000F00123F000900023O00202O00090009000700122O000B00086O0009000B000200202O00090009000900202O00090009000A00202O00090009001000122O000B00116O0009000B000200202O00090009000F4O00080008000900202O00060008001200202O00080004000F00122O000900023O00202O00090009000700122O000B00086O0009000B000200202O00090009000900202O00090009000A00202O00090009001000122O000B00116O0009000B000200202O00090009000F4O00080008000900202O00070008001300122O000500143O00260F00050018000100140004213O001800010012280008000B3O0020B30008000800150006520007004A000100080004213O004A0001001228000800023O00203E00080008000700122O000A00086O0008000A000200202O00080008000900202O00080008000A00202O00080008001000122O000A00116O0008000A000200122O0009000B3O00202O0009000900154O00090006000900102O00080016000900044O004A00010004213O001800010006AC3O0007000100020004213O000700012O00AF3O00017O000B3O00028O0003043O005465787403063O00737472696E6703063O00666F726D6174030A3O00252E3266207374756473026O00144003103O004261636B67726F756E64436F6C6F723303063O00436F6C6F72332O033O006E6577026O00F03F026O002040012B3O001224000100013O00260F00010001000100010004213O000100012O006100025O00127F000300033O00202O00030003000400122O000400056O00058O00030005000200102O00020002000300264O0015000100060004213O001500012O006100025O001235000300083O00202O00030003000900122O000400013O00122O0005000A3O00122O000600016O00030006000200102O00020007000300044O002A00010026103O00200001000B0004213O002000012O006100025O001235000300083O00202O00030003000900122O0004000A3O00122O0005000A3O00122O000600016O00030006000200102O00020007000300044O002A00012O006100025O001235000300083O00202O00030003000900122O0004000A3O00122O000500013O00122O000600016O00030006000200102O00020007000300044O002A00010004213O000100012O00AF3O00017O00053O00028O00026O00F03F03093O00436861726163746572027O004003103O00546F7563685472616E736D692O74657200403O0012243O00014O006C000100033O000E890001000700013O0004213O00070001001224000100014O006C000200023O0012243O00023O000E890002000200013O0004213O000200012O006C000300033O00260F00010013000100010004213O001300012O006100045O0006BB00040010000100010004213O001000012O00AF3O00014O0061000400013O0020B3000200040003001224000100023O000E8900020037000100010004213O00370001001224000400013O00260F0004001A000100020004213O001A0001001224000100043O0004213O0037000100260F00040016000100010004213O001600012O0061000500024O006A000600024O00B40005000200022O006A000300053O0006BA0003003500013O0004213O003500012O0061000500034O001F000600033O00122O000700056O000800046O00050008000200062O0005003500013O0004213O00350001001224000500013O00260F0005002A000100010004213O002A00012O0061000600054O0016000700026O0006000200014O000600066O000700026O000800036O00060008000100044O003500010004213O002A0001001224000400023O0004213O0016000100260F0001000A000100040004213O000A00012O009200046O0019000400073O0004213O003F00010004213O000A00010004213O003F00010004213O000200012O00AF3O00017O00093O00028O00026O00F03F03073O0056697369626C6503093O0043686172616374657203063O00506172656E7403093O00776F726B737061636503083O00506F736974696F6E03103O0048756D616E6F6964522O6F745061727403093O004D61676E697475646500333O0012243O00014O006C000100033O00260F3O0007000100010004213O00070001001224000100014O006C000200023O0012243O00023O00260F3O0002000100020004213O000200012O006C000300033O00260F00010014000100010004213O001400012O006100045O0020B30004000400030006BB00040011000100010004213O001100012O00AF3O00014O0061000400013O0020B3000200040004001224000100023O00260F0001000A000100020004213O000A00012O0061000400024O006A000500024O00B40004000200022O006A000300043O0006BA0003003200013O0004213O003200010020B3000400030005001228000500063O00068C00040032000100050004213O00320001001224000400014O006C000500053O00260F00040022000100010004213O002200010020B300060003000700207C00070002000800202O0007000700074O00060006000700202O0005000600094O000600036O000700056O00060002000100044O003200010004213O002200010004213O003200010004213O000A00010004213O003200010004213O000200012O00AF3O00017O00053O0003103O00496E6469636174696F6E546F2O676C6503053O0056616C756503073O0056697369626C653O012O000B4O00617O0020B35O00010020B35O00020006BA3O000800013O0004213O000800012O00613O00013O0030743O000300040004213O000A00012O00613O00013O0030743O000300052O00AF3O00017O00013O00030A3O006669726553657276657200084O00447O00206O00014O000200016O000300026O000400048O00049O008O00017O000D3O0003043O007461736B03043O0077616974029A5O99D93F028O0003053O007063612O6C03043O007761726E03113O00427970612O732074696D6564206F75742E026O00344003043O0067616D65030A3O004765745365727669636503073O00506C6179657273030B3O004C6F63616C506C6179657203043O004B69636B00293O0012283O00013O0020B35O0002001224000100034O00B43O000200020006BA3O002800013O0004213O002800010012243O00044O006C000100023O00260F3O0008000100040004213O00080001001228000300054O004600048O0003000200044O000200046O000100033O00062O0001001300013O0004213O001300010006BA00023O00013O0004215O00012O00B6000300023O0012A7000400063O00122O000500076O00040002000200122O000500013O00202O00050005000200122O000600086O00050002000200122O000600093O00202O00060006000A00122O0008000B6O00060008000200202O00060006000C00202O00060006000D00122O000800076O000600086O00033O00012O005C000300023O0004215O00010004213O000800010004215O00012O00AF3O00017O00013O0003053O00436C6F636B00084O004A00015O00202O0001000100014O00028O00013O00024O000200016O0001000100024O000100028O00017O00103O00028O0003113O006765746E616D6563612O6C6D6574686F64026O00F03F030B3O00636865636B63612O6C6572030A3O0046697265536572766572030A3O006669726553657276657203063O00737472696E6703043O0066696E6403023O00414303043O0074797065027O004003053O007461626C65026O00334003093O00636F726F7574696E6503053O007969656C6403083O004E616D6563612O6C01483O001224000200014O006C000300043O000E890001000C000100020004213O000C0001001228000500024O002C0005000100024O000300056O00058O00068O00053O00012O006A000400053O001224000200033O00260F00020002000100030004213O00020001001228000500044O008B0005000100020006BB00050040000100010004213O004000012O006100055O00068C3O0040000100050004213O0040000100265500030019000100050004213O0019000100260F00030040000100060004213O00400001001228000500073O00208A00050005000800202O00060004000300122O000700096O00050007000200062O0005004000013O0004213O004000012O0061000500013O0006BB0005003C000100010004213O003C00010012280005000A3O0020B300060004000B2O00B400050002000200260F000500400001000C0004213O004000010020B300050004000B2O007A000500053O00260F000500400001000D0004213O00400001001224000500014O006C000600063O00260F0005002E000100010004213O002E0001001224000600013O000E8900010031000100060004213O003100010020B30007000400032O0019000700023O0020B300070004000B2O0019000700013O0004213O004000010004213O003100010004213O004000010004213O002E00010004213O004000010012280005000E3O0020B300050005000F2O00C1000500014O009100056O0061000500033O00204F0005000500104O00068O00078O00058O00055O00044O000200012O00AF3O00019O003O00014O00AF3O00017O00", GetFEnv(), ...);