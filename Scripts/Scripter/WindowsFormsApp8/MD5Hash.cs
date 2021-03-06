﻿using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Text.RegularExpressions;

namespace WindowsFormsApp8
{
    public static class Md5Hash
    {
        internal static string Compute(byte[] inputBytes)
        {
            byte[] hash;

            using (var md5 = MD5.Create())
            {
                hash = md5.ComputeHash(inputBytes);
            }

            var sb = new StringBuilder();
            foreach (var b in hash)
            {
                sb.Append(b.ToString("x2"));
            }

            return sb.ToString();
        }

        internal static string Compute(string input)
        {
            return Compute(Encoding.UTF8.GetBytes(input));
        }

        internal static string Compute(string input, string salt)
        {
            if (string.IsNullOrEmpty(salt))
            {
                return Compute(input);
            }

            return Compute(Compute(input) + Compute(salt));
        }

        internal static string ComputeFromFile(string path)
        {
            if (!File.Exists(path))
            {
                return string.Empty;
            }

            return Compute(File.ReadAllBytes(path));
        }

        internal static bool IsValid(string hash)
        {
            return new Regex("[0-9a-f]{32}").Match(hash.ToLower()).Success;
        }

        internal static bool Compare(string hash1, string hash2, bool skipInvalidHash = false)
        {
            if (!IsValid(hash1.ToLower()) || !IsValid(hash2.ToLower()))
            {
                return skipInvalidHash;
            }

            return string.Equals(hash1.ToLower(), hash2.ToLower(), StringComparison.CurrentCultureIgnoreCase);
        }
    }
}
