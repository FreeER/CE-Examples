// tutorial-step8.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include <windows.h>
#include <tchar.h>
#include <iostream>
#include <TlHelp32.h>
#include <random>
using namespace std;

// https://stackoverflow.com/questions/26572459/c-get-module-base-address-for-64bit-application
DWORD dwGetModuleBaseAddress(DWORD dwProcessID, TCHAR *lpszModuleName)
{
	HANDLE hSnapshot = CreateToolhelp32Snapshot(TH32CS_SNAPMODULE, dwProcessID);
	DWORD dwModuleBaseAddress = 0;
	if (hSnapshot != INVALID_HANDLE_VALUE)
	{
		MODULEENTRY32 ModuleEntry32 = { 0 };
		ModuleEntry32.dwSize = sizeof(MODULEENTRY32);
		if (Module32First(hSnapshot, &ModuleEntry32))
		{
			do
			{
				if (_tcscmp(ModuleEntry32.szModule, lpszModuleName) == 0)
				{
					dwModuleBaseAddress = (DWORD)ModuleEntry32.modBaseAddr;
					break;
				}
			} while (Module32Next(hSnapshot, &ModuleEntry32));
		}
		CloseHandle(hSnapshot);
	}
	return dwModuleBaseAddress;
}

// FreeER's code
DWORD readPointerChain(HANDLE phandle, DWORD base, int* offsets, size_t numOffsets)
{
	DWORD addr = base;
	SIZE_T read;
	for (size_t i = 0; i < numOffsets; i++)
	{
		BOOL success = ReadProcessMemory(phandle, (void*)addr, &addr, sizeof(addr), &read);
		if (!success) { cout << " failed to read " << hex << addr; return 0; }
		addr += offsets[i];
		//cout << "end address " << hex << addr << endl;
	}
	return addr;
}

int main()
{
	HWND hwnd = FindWindow(NULL, _T("Tutorial-i386"));
	if (!hwnd) { printf("Start the tut!\n"); cin.get(); return 1; }

	DWORD pid;
	GetWindowThreadProcessId(hwnd, &pid);
	DWORD moduleBase = dwGetModuleBaseAddress(pid, _T("Tutorial-i386.exe"));

	long base = moduleBase + 0x1FD660;
	//cout << hex << base << endl;
	int offsets[] = {0xC,0x14,0, 0x18};

	HANDLE phandle = OpenProcess(PROCESS_QUERY_INFORMATION | PROCESS_VM_READ | PROCESS_VM_WRITE, 0, pid);
	if (!phandle) { printf("Failed to open!\n"); cin.get(); return 1; }

	DWORD addr = readPointerChain(phandle, base, offsets, sizeof(offsets) / sizeof(*offsets));
	if (!addr) { cout << "Failed to follow path" << endl; cin.get(); return 1; }

	DWORD val, read;
	BOOL success = ReadProcessMemory(phandle, (void*)addr, &val, sizeof(val), &read);
	cout << "val at " << hex << addr << " is " << dec << val << endl;

	// http://www.cplusplus.com/reference/random/
	std::default_random_engine generator;
	std::uniform_int_distribution<int> distribution(100, 1000);
	int dice_roll = distribution(generator);  // generates number in the range 100..1000
	val = val + dice_roll;
	WriteProcessMemory(phandle, (void*)addr, &val, sizeof(val), &read);

	success = ReadProcessMemory(phandle, (void*)addr, &val, sizeof(val), &read);
	cout << "val at " << hex << addr << " is now " << dec << val << endl;
	cin.get();

	return 0;
}

