// Copyright (c) Microsoft. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for full license information.

using System;

namespace System.Runtime.InteropServices.ComTypes
{
    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    public struct ELEMDESC
    {
        public TYPEDESC tdesc;

        [StructLayout(LayoutKind.Explicit, CharSet = CharSet.Unicode)]
        public struct DESCUNION
        {
            [FieldOffset(0)]
            public IDLDESC idldesc;
            [FieldOffset(0)]
            public PARAMDESC paramdesc;
        };
        public DESCUNION desc;
    }
}
