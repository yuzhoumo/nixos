/* LD_PRELOAD constructor that drops capabilities in non-VPN subprocesses.
 *
 * NixOS's security.wrappers raises CAP_NET_ADMIN via ambient caps, which
 * propagates to every subprocess including the gdbus helper that calls
 * org.freedesktop.portal.OpenURI for AAD browser launch. Portal (no caps)
 * can't readlink /proc/$gdbus/root and refuses with AccessDenied.
 *
 * In trusted VPN binaries: set PR_SET_DUMPABLE so /proc is readable.
 * In everything else: drop all caps so portal can identify the process.
 */

#define _GNU_SOURCE
#include <errno.h>
#include <string.h>
#include <unistd.h>
#include <sys/prctl.h>
#include <sys/syscall.h>
#include <linux/capability.h>

#ifndef PR_CAP_AMBIENT
#define PR_CAP_AMBIENT 47
#endif
#ifndef PR_CAP_AMBIENT_CLEAR_ALL
#define PR_CAP_AMBIENT_CLEAR_ALL 4
#endif

static int is_trusted(const char *path) {
    if (!path) return 0;
    const char *base = strrchr(path, '/');
    base = base ? base + 1 : path;
    return strcmp(base, "microsoft-azurevpnclient") == 0
        || strcmp(base, "azurevpnclient-unprivileged") == 0
        || strcmp(base, "azurevpnclient") == 0;
}

__attribute__((constructor))
static void azurevpn_relax(void) {
    if (is_trusted(program_invocation_name)) {
        prctl(PR_SET_DUMPABLE, 1, 0, 0, 0);
        return;
    }

    prctl(PR_CAP_AMBIENT, PR_CAP_AMBIENT_CLEAR_ALL, 0, 0, 0);
    struct __user_cap_header_struct hdr = {
        .version = _LINUX_CAPABILITY_VERSION_3,
        .pid = 0,
    };
    struct __user_cap_data_struct data[2] = { {0}, {0} };
    syscall(SYS_capset, &hdr, data);
}
